json.extract! @copy, :id, :barcode, :status
json.loanable_type @copy.loanable_type
json.loanable_id   @copy.loanable_id