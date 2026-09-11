require "test_helper"

class BookingTest < ActiveSupport::TestCase
  setup do
    @customer = User.create!(name: "Customer", email: "customer@example.test", password: "password123", password_confirmation: "password123")
    @provider = User.create!(name: "Provider", email: "provider@example.test", password: "password123", password_confirmation: "password123", role: :provider)
    @service = @provider.provider_profile.services.create!(
      name: "Consultation", description: "One hour consultation", category: Category.create!(name: "Consulting"),
      price: 50, duration: 60, status: :active
    )
    @provider.provider_profile.availability_slots.create!(day_of_week: 1, starts_at: "09:00", ends_at: "17:00")
  end

  test "rejects a booking outside provider availability" do
    booking = build_booking("2026-09-14 08:00")

    assert_not booking.valid?
    assert_includes booking.errors[:start_time], "is outside the provider's availability"
  end

  test "rejects overlapping non-cancelled bookings" do
    build_booking("2026-09-14 10:00").save!
    overlapping = build_booking("2026-09-14 10:30")

    assert_not overlapping.valid?
    assert_includes overlapping.errors[:start_time], "overlaps an existing appointment"
  end

  test "allows the same time after the conflicting booking is cancelled" do
    booking = build_booking("2026-09-14 10:00")
    booking.save!
    booking.cancel!(cancelled_by: @customer)

    assert build_booking("2026-09-14 10:00").valid?
  end

  private

  def build_booking(time)
    start_time = Time.zone.parse(time)
    Booking.new(user: @customer, service: @service, start_time: start_time, end_time: start_time + 60.minutes)
  end
end
