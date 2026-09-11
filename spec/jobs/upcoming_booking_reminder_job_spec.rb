require "rails_helper"

RSpec.describe UpcomingBookingReminderJob do
  include ActiveSupport::Testing::TimeHelpers

  it "creates one reminder for a confirmed booking tomorrow" do
    travel_to Time.zone.local(2026, 9, 11, 10) do
      customer = create_user
      provider = create_user(role: :provider)
      make_provider_available(provider, day: 1)
      service = create_service(provider: provider)
      start_time = 24.hours.from_now.change(min: 0)
      make_provider_available(provider, day: start_time.wday) unless start_time.wday == 1
      booking = Booking.create!(user: customer, service: service, start_time: start_time, end_time: start_time + 60.minutes, status: :confirmed)

      described_class.perform_now
      described_class.perform_now

      expect(customer.notifications.where(notifiable: booking, title: "Appointment reminder").count).to eq(1)
    end
  end
end
