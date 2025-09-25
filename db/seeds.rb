# frozen_string_literal: true

require "faker"

SEED = Integer(ENV.fetch("SEED", 42))
rng  = Random.new(SEED)
Faker::Config.locale = "en"
Faker::Config.random = rng

ActiveRecord::Base.transaction do
  # Idempotent reset of domain data (keep users if you want; here we rebuild all)
  Contribution.delete_all
  Loan.delete_all
  Copy.delete_all
  BookGenre.delete_all
  Genre.delete_all
  Person.delete_all
  Book.delete_all
  User.delete_all

  puts "== Users"
  lib = User.create!(name: "The Librarian", email_address: "librarian@example.com", password: "password", role: :librarian)
  members = 5.times.map { |i|
    User.create!(name: "Member #{i + 1}", email_address: "member#{i + 1}@example.com", password: "password", role: :member)
  }
  puts "   librarian: #{lib.email_address} / password"
  puts "   members: #{members.map(&:email_address).join(', ')} / password"

  puts "== Genres"
  genre_names = %w[Software Architecture Databases DevOps Testing AI Security UX]
  genres = genre_names.map { |name| Genre.create!(name:) }

  puts "== People (authors)"
  author_pool = Array.new(20) { Person.create!(name: Faker::Book.author) }

  puts "== Books with authors + genres"
  curated = [
    [ "Refactoring", "9780134757599" ],
    [ "Clean Code", "9780132350884" ],
    [ "Domain-Driven Design", "9780321125217" ],
    [ "Design Patterns", "9780201633610" ],
    [ "Accelerate", "9781942788331" ]
  ]
  books = curated.map { |title, isbn| Book.create!(title:, isbn:, language: %w[en pt es].sample(random: rng)) }

  # Add N random books deterministically
  25.times do
    # deterministic 13-digit code from RNG
    isbn = Array.new(13) { rng.rand(0..9) }.join
    books << Book.create!(title: Faker::Book.title, isbn:, language: %w[en pt es].sample(random: rng))
  end

  # Attach genres and authors deterministically
  books.sort_by!(&:title)
  books.each do |book|
    book.genre_ids = genres.sample(rng.rand(1..2), random: rng).map!(&:id)
    author_pool.sample(rng.rand(1..2), random: rng).each do |person|
      Contribution.create!(catalogable: book, agent: person, role: :author)
    end
  end

  puts "== Copies (0–3 per book)"
  books.each_with_index do |book, i|
    # 0..3 copies deterministically from index and RNG
    count = rng.rand(0..3)
    count.times do |n|
      Copy.create!(loanable: book, barcode: "B#{book.id}-#{n + 1}", status: :available)
    end
  end

  puts "== Loans (some active, some overdue)"
  # Deterministic selection: iterate books by title; for each with availability, loan to a member by round-robin.
  idx = 0
  books.each_with_index do |book, i|
    next unless book.copies.available.exists?
    borrower = members[idx % members.length]
    idx += 1

    # One loan per (borrower, book). No duplicates → no AlreadyBorrowed.
    loan = Loan::Create.call!(user: borrower, loanable: book)

    # Every 3rd → overdue, every 4th → returned (order matters; returning may clear overdue)
    if (i % 3).zero?
      loan.update!(borrowed_at: 10.days.ago, due_at: 5.days.ago)
    end
    if (i % 4).zero?
      Loan::Return.call!(librarian: lib, loan: loan)
    end
  end
end

puts "== Done (seed=#{SEED})"
