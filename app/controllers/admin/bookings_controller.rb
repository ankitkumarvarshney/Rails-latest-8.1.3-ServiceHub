class Admin::BookingsController < ApplicationController
  before_action :require_admin
  def index; @bookings = Booking.includes(:user, service: :provider_profile).order(created_at: :desc); end
end
