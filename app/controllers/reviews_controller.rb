class ReviewsController < ApplicationController
  before_action :require_login
  def new
    @booking = current_user.bookings.completed.find(params[:booking_id])
    @review = @booking.build_review
  end
  def create
    @booking = current_user.bookings.completed.find(params[:review][:booking_id])
    @review = @booking.build_review(review_params.merge(user: current_user))
    @review.save ? redirect_to(bookings_path, notice: "Thanks for your review.") : render(:new, status: :unprocessable_entity)
  end
  private
  def review_params; params.require(:review).permit(:booking_id, :rating, :comment); end
end
