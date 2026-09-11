class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :service
  belongs_to :provider_profile
  has_one :review, dependent: :destroy

  enum :status, { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }, default: :pending
  validates :start_time, :end_time, presence: true
  before_validation :assign_provider_profile, on: :create
  validate :end_after_start, :provider_is_available, :no_provider_conflict, :provider_matches_service
  validate :customer_is_customer

  scope :upcoming, -> { where("start_time > ?", Time.current).where.not(status: :cancelled) }

  def confirm!
    raise ActiveRecord::RecordInvalid, self unless pending?
    transaction { update!(status: :confirmed); notify_customer!("Booking confirmed", "Your appointment for #{service.name} has been confirmed.") }
  end

  def cancel!(cancelled_by: nil)
    raise ActiveRecord::RecordInvalid, self if completed? || cancelled?

    transaction do
      update!(status: :cancelled)
      notify_customer!("Booking cancelled", "Your appointment for #{service.name} has been cancelled.") unless cancelled_by == user
      notify_provider!("Booking cancelled", "The #{service.name} appointment on #{I18n.l(start_time, format: :short)} was cancelled.") unless cancelled_by == provider_profile.user
    end
  end

  def complete!
    raise ActiveRecord::RecordInvalid, self unless confirmed?
    update!(status: :completed)
  end

  private

  def end_after_start
    errors.add(:end_time, "must be after start time") if start_time.present? && end_time.present? && end_time <= start_time
  end

  def customer_is_customer
    errors.add(:user, "must be a customer") unless user&.customer?
  end

  def provider_is_available
    return if service.blank? || start_time.blank? || end_time.blank?
    errors.add(:start_time, "is outside the provider's availability") unless service.provider_profile.availability_slots.any? { |slot| slot.covers?(start_time, end_time) }
  end

  def no_provider_conflict
    return if service.blank? || start_time.blank? || end_time.blank?
    conflicts = Booking.joins(:service).where(services: { provider_profile_id: service.provider_profile_id }).where.not(status: :cancelled).where.not(id: id).where("bookings.start_time < ? AND bookings.end_time > ?", end_time, start_time)
    errors.add(:start_time, "overlaps an existing appointment") if conflicts.exists?
  end

  def provider_matches_service
    return if service.blank? || provider_profile.blank? || service.provider_profile_id == provider_profile_id
    errors.add(:provider_profile, "must belong to the selected service")
  end

  def notify_customer!(title, body)
    Notification.create!(user: user, title: title, body: body, notifiable: self)
  end

  def notify_provider!(title, body)
    Notification.create!(user: provider_profile.user, title: title, body: body, notifiable: self)
  end

  def assign_provider_profile
    self.provider_profile ||= service&.provider_profile
  end
end
