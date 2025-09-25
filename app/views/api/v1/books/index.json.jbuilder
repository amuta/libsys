json.array! @books do |b|
  json.partial! "api/v1/books/book", book: b
end
