require "rails_helper"

RSpec.describe "core models" do
  it "creates a provider profile and validates user email uniqueness" do
    provider = create_user(role: :provider, email: "provider@example.test")
    duplicate = User.new(name: "Duplicate", email: "provider@example.test", password: "password123")

    expect(provider.provider_profile.business_name).to eq("Provider User's Services")
    expect(duplicate).not_to be_valid
  end

  it "validates availability ranges and checks coverage" do
    provider = create_user(role: :provider)
    slot = make_provider_available(provider)
    start_time = Time.zone.parse("2026-09-14 10:00")

    expect(slot.covers?(start_time, start_time + 60.minutes)).to be(true)
    expect(slot.covers?(start_time, Time.zone.parse("2026-09-15 10:00"))).to be(false)
    expect(provider.provider_profile.availability_slots.build(day_of_week: 1, starts_at: "10:00", ends_at: "10:00")).not_to be_valid
  end

  it "permits reviews only from the completed booking customer" do
    customer = create_user
    provider = create_user(role: :provider)
    make_provider_available(provider)
    service = create_service(provider: provider)
    start_time = Time.zone.parse("2026-09-14 10:00")
    booking = Booking.create!(user: customer, service: service, start_time: start_time, end_time: start_time + 60.minutes, status: :confirmed)
    booking.complete!

    expect(Review.new(user: customer, booking: booking, rating: 5)).to be_valid
    expect(Review.new(user: provider, booking: booking, rating: 5)).not_to be_valid
  end
end
