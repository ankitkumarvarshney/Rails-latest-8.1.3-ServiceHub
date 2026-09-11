class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :booking, null: false, foreign_key: true, index: { unique: true }
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end

    add_check_constraint :reviews, "rating BETWEEN 1 AND 5", name: "reviews_rating_is_valid"
  end
end
