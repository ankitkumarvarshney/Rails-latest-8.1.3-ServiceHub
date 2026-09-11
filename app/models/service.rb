class Service < ApplicationRecord
  belongs_to :provider_profile
  belongs_to :category
  has_many :bookings, dependent: :restrict_with_error

  enum :status, { draft: 0, active: 1, inactive: 2 }, default: :draft
  validates :name, :description, :price, :duration, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :duration, numericality: { only_integer: true, greater_than: 0 }

  scope :visible, -> { active.includes(:category, provider_profile: :user) }
  scope :search, ->(term) { term.present? ? where("services.name ILIKE :q OR services.description ILIKE :q", q: "%#{sanitize_sql_like(term)}%") : all }

  def average_rating
    bookings.joins(:review).average("reviews.rating")&.round(1) || 0
  end
end
