json.array! @loans do |l|
  json.partial! "api/v1/loans/loan", loan: l
end
