require "rails_helper"

RSpec.describe Booking do
  let(:customer) { create_user }
  let(:provider) { create_user(role: :provider) }
  let(:service) { create_service(provider: provider) }
  let(:start_time) { Time.zone.parse("2026-09-14 10:00") }

  before { make_provider_available(provider) }

  def booking_at(time)
    described_class.new(user: customer, service: service, start_time: time, end_time: time + service.duration.minutes)
  end

  it "accepts available customer bookings and assigns the service provider" do
    booking = booking_at(start_time)

    expect(booking).to be_valid
    expect(booking.provider_profile).to eq(provider.provider_profile)
  end

  it "rejects unavailable and overlapping appointments" do
    expect(booking_at(Time.zone.parse("2026-09-14 08:00"))).not_to be_valid

    booking_at(start_time).save!
    expect(booking_at(start_time + 30.minutes)).not_to be_valid
  end

  it "confirms, notifies, and then allows a cancelled time to be reused" do
    booking = booking_at(start_time)
    booking.save!
    booking.confirm!

    expect(customer.notifications.last.title).to eq("Booking confirmed")

    booking.cancel!(cancelled_by: customer)
    expect(booking_at(start_time)).to be_valid
  end
end
