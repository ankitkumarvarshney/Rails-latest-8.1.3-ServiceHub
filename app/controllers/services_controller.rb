class ServicesController < ApplicationController
  before_action :require_provider, except: %i[index show]
  before_action :set_service, only: %i[show edit update destroy]
  def index
    @categories = Category.order(:name)
    @services = Service.visible.search(params[:q]).yield_self { |scope| params[:category_id].present? ? scope.where(category_id: params[:category_id]) : scope }.order(created_at: :desc)
  end
  def show; end
  def new; @service = current_user.provider_profile.services.build; end
  def create
    @service = current_user.provider_profile.services.build(service_params)
    @service.save ? redirect_to(@service, notice: "Service created.") : render(:new, status: :unprocessable_entity)
  end
  def edit; nil unless authorize_owner!; end
  def update
    return unless authorize_owner!
    @service.update(service_params) ? redirect_to(@service, notice: "Service updated.") : render(:edit, status: :unprocessable_entity)
  end
  def destroy
    return unless authorize_owner!
    @service.destroy ? redirect_to(services_path, notice: "Service deleted.") : redirect_to(@service, alert: @service.errors.full_messages.to_sentence)
  end
  private
  def set_service; @service = Service.find(params[:id]); end
  def authorize_owner!
    return true if admin? || @service.provider_profile == current_user.provider_profile

    redirect_to root_path, alert: "That service is not yours."
    false
  end
  def service_params; params.require(:service).permit(:name, :description, :category_id, :price, :duration, :status); end
end
