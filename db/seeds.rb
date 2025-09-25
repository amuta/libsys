# frozen_string_literal: true

require "faker"

Faker::Config.locale = "en"

ActiveRecord::Base.transaction do
  puts "== Users"
  lib = User.find_or_create_by!(email_address: "librarian@example.com") do |u|
    u.name = "The Librarian"
    u.password = "password"
    u.role     = :librarian
  end
  members = 5.times.map do |i|
    User.find_or_create_by!(email_address: "member#{i+1}@example.com") do |u|
      u.name = "Member Num#{i+1}"
      u.password = "password"
      u.role     = :member
    end
  end
  puts "   librarian: #{lib.email_address} / password"
  puts "   members: #{members.map(&:email_address).join(", ")} / password"

  puts "== Genres"
  genre_names = %w[Software Architecture Databases DevOps Testing AI Security UX]
  genres = genre_names.map { |name| Genre.find_or_create_by!(name:) }

  puts "== People (authors)"
  author_pool = []
  20.times do
    name = Faker::Book.unique.author
    author_pool << Person.find_or_create_by!(name:)
  end

  puts "== Books with authors + genres"
  # Seed a few well-known CS titles first
  curated = [
    [ "Refactoring",            "9780134757599" ],
    [ "Clean Code",             "9780132350884" ],
    [ "Domain-Driven Design",   "9780321125217" ],
    [ "Design Patterns",        "9780201633610" ],
    [ "Accelerate",             "9781942788331" ]
  ]
  books = []

  curated.each do |title, isbn|
    b = Book.find_or_create_by!(isbn:) do |book|
      book.title    = title
      book.language = %w[en en en en en pt es].sample
    end
    books << b
  end

  # Random additional books
  25.times do
    isbn = loop do
      v = Faker::Number.number(digits: 13)
      break v unless Book.exists?(isbn: v)
    end
    b = Book.find_or_create_by!(isbn:) do |book|
      book.title    = Faker::Book.unique.title
      book.language = %w[en pt es].sample
    end
    books << b
  end

  # Attach genres and authors
  books.each do |book|
    # genres (1–2)
    book.genre_ids = genres.sample(rand(1..2)).map(&:id)

    # authors (1–2)
    selected_authors = author_pool.sample(rand(1..2))
    selected_authors.each do |person|
      Contribution.find_or_create_by!(catalogable: book, agent: person, role: :author)
    end
  end

  puts "== Copies (0–3 per book)"
  books.each do |book|
    next if book.copies.count >= 1 && book.copies.count <= 3 # keep idempotent-ish

    # Clear existing and recreate a small random set for determinism on re-seed
    book.copies.destroy_all
    rand(0..3).times do |n|
      Copy.create!(
        loanable: book,
        barcode: "B#{book.id}-#{n+1}",
        status: :available
      )
    end
  end

  puts "== Loans (some active, some overdue)"
  # Borrow up to 12 available books across members
  available_books = books.select { |b| b.copies.available.exists? }
  available_books.sample([ available_books.size, 12 ].min).each_with_index do |book, i|
    borrower = members.sample
    loan = Loan::Create.call!(user: borrower, loanable: book) # sets due_at = 14 days out

    # Mark about 1/3 as overdue by moving due_at into the past
    if i % 3 == 0
      loan.update!(borrowed_at: 10.days.ago, due_at: 5.days.ago)
    end

    # Mark about 1/4 as already returned
    if i % 4 == 0
      Loan::Return.call!(librarian: lib, loan: loan)
    end
  end
end

puts "== Done"
