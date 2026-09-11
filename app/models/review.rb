class Review < ApplicationRecord
  belongs_to :user
  belongs_to :booking
  validates :rating, inclusion: { in: 1..5 }
  validates :booking_id, uniqueness: true
  validate :completed_booking_by_customer

  private
  def completed_booking_by_customer
    return if booking&.completed? && booking.user_id == user_id
    errors.add(:booking, "must be your completed booking")
  end
end
