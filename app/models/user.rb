class User < ApplicationRecord
  has_secure_password

  has_one :provider_profile, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :notifications, dependent: :destroy

  enum :role, { customer: 0, provider: 1, admin: 2 }, default: :customer

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  after_create :create_default_provider_profile!, if: :provider?

  private
  def create_default_provider_profile!
    create_provider_profile!(business_name: "#{name}'s Services")
  end
end
