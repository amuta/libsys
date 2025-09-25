module Loan::Rules
  extend ActiveSupport::Concern
  included do
    validate :copy_is_available, on: :create
    validate :due_after_borrowed
  end
  private
  def copy_is_available = errors.add(:copy, "not available") unless copy&.available?
  def due_after_borrowed
    return if borrowed_at.blank? || due_at.blank?
    errors.add(:due_at, "must be after borrowed_at") if due_at <= borrowed_at
  end
end
