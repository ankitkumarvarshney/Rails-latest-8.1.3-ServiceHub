class ProviderProfile < ApplicationRecord
  belongs_to :user
  has_many :services, dependent: :destroy
  has_many :availability_slots, dependent: :destroy
  has_many :bookings, through: :services

  validates :business_name, presence: true
  delegate :name, :email, to: :user

  def average_rating
    Review.joins(booking: :service)
      .where(services: { provider_profile_id: id })
      .average(:rating)&.round(1) || 0
  end
end
