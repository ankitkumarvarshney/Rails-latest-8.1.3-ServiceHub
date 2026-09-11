class Admin::ReviewsController < ApplicationController
  before_action :require_admin
  def index; @reviews = Review.includes(:user, booking: :service).order(created_at: :desc); end
end
