class CreateProviderProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :provider_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :business_name, null: false
      t.text :bio
      t.string :phone

      t.timestamps
    end
  end
end
