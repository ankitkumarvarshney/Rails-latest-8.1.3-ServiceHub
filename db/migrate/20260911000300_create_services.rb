class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :duration, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :services, %i[status category_id]
    add_check_constraint :services, "price >= 0", name: "services_price_is_nonnegative"
    add_check_constraint :services, "duration > 0", name: "services_duration_is_positive"
  end
end
