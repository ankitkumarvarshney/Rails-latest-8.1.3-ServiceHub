class AvailabilitySlot < ApplicationRecord
  belongs_to :provider_profile
  validates :day_of_week, inclusion: { in: 0..6 }
  validates :starts_at, :ends_at, presence: true
  validate :ends_after_start

  def covers?(start_time, end_time)
    day_of_week == start_time.wday && start_time.to_date == end_time.to_date &&
      starts_at.seconds_since_midnight <= start_time.seconds_since_midnight &&
      ends_at.seconds_since_midnight >= end_time.seconds_since_midnight
  end

  private

  def ends_after_start
    errors.add(:ends_at, "must be after the start time") if starts_at.present? && ends_at.present? && ends_at <= starts_at
  end
end
