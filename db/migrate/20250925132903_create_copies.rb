class CreateCopies < ActiveRecord::Migration[8.0]
  def change
    create_table :copies do |t|
      t.references :loanable, polymorphic: true, null: false
      t.string :barcode
      t.integer :status

      t.timestamps
    end
  end
end
