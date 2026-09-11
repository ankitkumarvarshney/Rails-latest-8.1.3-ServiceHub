class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    enable_extension "btree_gist"

    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.references :provider_profile, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :status, null: false, default: 0
      t.text :customer_note

      t.timestamps
    end

    add_index :bookings, %i[service_id start_time]
    add_index :bookings, %i[user_id start_time]
    add_index :bookings, %i[provider_profile_id start_time]
    add_check_constraint :bookings, "end_time > start_time", name: "bookings_time_order"
    add_check_constraint :bookings, "status IN (0, 1, 2, 3)", name: "bookings_status_is_valid"
    add_exclusion_constraint :bookings,
      "provider_profile_id WITH =, tsrange(start_time, end_time, '[)') WITH &&",
      where: "status <> 3",
      using: :gist,
      name: "bookings_provider_time_no_overlap"
  end
end
