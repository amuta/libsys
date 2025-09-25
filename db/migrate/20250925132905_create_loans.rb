class CreateLoans < ActiveRecord::Migration[8.0]
  def change
    create_table :loans do |t|
      t.references :copy, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :loanable, polymorphic: true, null: false
      t.datetime :borrowed_at
      t.datetime :due_at
      t.datetime :returned_at
      t.integer :status

      t.timestamps
    end
  end
end
