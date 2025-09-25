json.extract! loan, :id, :status, :borrowed_at, :due_at, :returned_at, :copy_id
json.loanable_type  loan.loanable_type
json.loanable_id    loan.loanable_id
json.title loan.copy.loanable.try(:title)
json.loanable_title loan.copy.loanable.try(:title)
json.overdue        loan.overdue?
json.status_now     loan.status_now

if Current.user&.librarian?
  json.user_id loan.user_id
  json.user_email loan.user.email_address
  json.user_name(loan.user.name)
end
