class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.datetime :read_at
      t.references :notifiable, polymorphic: true

      t.timestamps
    end

    add_index :notifications, %i[user_id read_at]
  end
end
