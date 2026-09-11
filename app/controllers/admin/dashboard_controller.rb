class Admin::DashboardController < ApplicationController
  before_action :require_admin
  def index
    @stats = { users: User.count, providers: User.provider.count, services: Service.count, bookings: Booking.count, reviews: Review.count, confirmed: Booking.confirmed.count, revenue: Booking.completed.joins(:service).sum("services.price") }
    @recent_bookings = Booking.includes(:user, service: :provider_profile).order(created_at: :desc).limit(8)
  end
end
