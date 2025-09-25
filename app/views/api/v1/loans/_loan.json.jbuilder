json.extract! loan, :id, :status, :borrowed_at, :due_at, :returned_at, :copy_id
json.loanable_type loan.loanable_type
json.loanable_id   loan.loanable_id
json.title         loan.copy.loanable.try(:title)