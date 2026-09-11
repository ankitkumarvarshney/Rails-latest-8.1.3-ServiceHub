require "rails_helper"

RSpec.describe "booking workflow" do
  let(:customer) { create_user }
  let(:provider) { create_user(role: :provider) }
  let(:service) { create_service(provider: provider) }
  let(:start_time) { Time.zone.parse("2026-09-14 10:00") }

  before { make_provider_available(provider) }

  it "creates, confirms, completes, reviews, and marks notifications as read" do
    sign_in(customer)
    get new_booking_path(service_id: service.id)
    expect(response).to have_http_status(:ok)

    post bookings_path(service_id: service.id), params: { booking: { start_time: start_time, customer_note: "Please use light pressure." } }
    booking = Booking.last
    expect(response).to redirect_to(booking)

    delete session_path
    sign_in(provider)
    patch confirm_booking_path(booking)
    expect(booking.reload).to be_confirmed
    patch complete_booking_path(booking)
    expect(booking.reload).to be_completed

    delete session_path
    sign_in(customer)
    post reviews_path, params: { review: { booking_id: booking.id, rating: 5, comment: "Excellent" } }
    expect(response).to redirect_to(bookings_path)

    get notifications_path
    expect(response).to have_http_status(:ok)
    patch mark_all_read_notifications_path
    expect(customer.notifications.unread).to be_empty
  end
end
