class CreateContributions < ActiveRecord::Migration[8.0]
  def change
    create_table :contributions do |t|
      t.references :catalogable, polymorphic: true, null: false
      t.references :agent, polymorphic: true, null: false
      t.integer :role
      t.integer :position
      t.string :note

      t.timestamps
    end
  end
end
