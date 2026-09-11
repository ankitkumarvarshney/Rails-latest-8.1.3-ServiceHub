class CreateAvailabilitySlots < ActiveRecord::Migration[8.1]
  def change
    create_table :availability_slots do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :starts_at, null: false
      t.time :ends_at, null: false

      t.timestamps
    end

    add_index :availability_slots, %i[provider_profile_id day_of_week]
    add_check_constraint :availability_slots, "day_of_week BETWEEN 0 AND 6", name: "availability_slots_day_is_valid"
    add_check_constraint :availability_slots, "ends_at > starts_at", name: "availability_slots_time_order"
  end
end
