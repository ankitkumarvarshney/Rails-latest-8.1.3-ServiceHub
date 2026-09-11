class BookingsController < ApplicationController
  before_action :require_login
  before_action :set_booking, only: %i[show confirm cancel complete]

  def index
    @bookings = if provider?
      Booking.joins(:service).where(services: { provider_profile_id: current_user.provider_profile.id }).includes(:user, service: :category).order(start_time: :desc)
    else
      current_user.bookings.includes(service: [ :category, provider_profile: :user ]).order(start_time: :desc)
    end
  end

  def show; end

  def new
    redirect_to root_path, alert: "Only customers can make bookings." and return unless current_user.customer?
    @service = Service.visible.find(params[:service_id])
    @booking = @service.bookings.build
  end

  def create
    redirect_to root_path, alert: "Only customers can make bookings." and return unless current_user.customer?
    @service = Service.visible.find(params[:service_id])
    start_time = Time.zone.parse(booking_params[:start_time].to_s)
    @booking = current_user.bookings.build(booking_params.merge(service: @service, provider_profile: @service.provider_profile, start_time: start_time, end_time: start_time && start_time + @service.duration.minutes))
    Booking.transaction do
      @booking.save!
      Notification.create!(user: current_user, title: "Booking requested", body: "Your #{ @service.name } appointment is pending confirmation.", notifiable: @booking)
      Notification.create!(user: @service.provider_profile.user, title: "New booking request", body: "#{current_user.name} requested #{@service.name} for #{I18n.l(@booking.start_time, format: :short)}.", notifiable: @booking)
    end
    redirect_to @booking, notice: "Booking requested."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def confirm
    return unless authorize_provider!
    return redirect_to(bookings_path, alert: "Only pending bookings can be confirmed.") unless @booking.pending?
    @booking.confirm!
    redirect_to bookings_path, notice: "Booking confirmed."
  end

  def cancel
    return unless authorize_participant!
    return redirect_to(bookings_path, alert: "Completed or already cancelled bookings cannot be cancelled.") if @booking.completed? || @booking.cancelled?
    @booking.cancel!(cancelled_by: current_user)
    redirect_to bookings_path, notice: "Booking cancelled."
  end

  def complete
    return unless authorize_provider!
    return redirect_to(bookings_path, alert: "Only confirmed bookings can be completed.") unless @booking.confirmed?
    @booking.complete!
    redirect_to bookings_path, notice: "Booking completed."
  end

  private
  def set_booking
     @booking = Booking.includes(:user, service: { provider_profile: :user }).find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:start_time, :customer_note)
   end

  def authorize_provider!
    return true if admin? || (provider? && @booking.provider_profile == current_user.provider_profile)

    redirect_to root_path, alert: "Only the provider can do that."
    false
  end

  def authorize_participant!
    return true if admin? || @booking.user == current_user || (provider? && @booking.provider_profile == current_user.provider_profile)

    redirect_to root_path, alert: "You cannot change this booking."
    false
  end
end
