class Admin::ServicesController < ApplicationController
  before_action :require_admin
  def index; @services = Service.includes(:category, provider_profile: :user).order(created_at: :desc); end
  def update; Service.find(params[:id]).update!(status: params.require(:service)[:status]); redirect_to admin_services_path, notice: "Service status updated."; end
end
