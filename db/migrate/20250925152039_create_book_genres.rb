class CreateBookGenres < ActiveRecord::Migration[8.0]
  def change
    create_table :book_genres do |t|
      t.references :book, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end

    add_index :book_genres, [ :book_id, :genre_id ], unique: true

    remove_reference :books, :genre
  end
end
