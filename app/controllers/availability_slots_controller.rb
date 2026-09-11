class AvailabilitySlotsController < ApplicationController
  before_action :require_provider

  def index
   @slots = current_user.provider_profile.availability_slots.order(:day_of_week, :starts_at)
  end

  def new
    @slot = current_user.provider_profile.availability_slots.build
  end

  def create
    @slot = current_user.provider_profile.availability_slots.build(slot_params)
    @slot.save ? redirect_to(availability_slots_path, notice: "Availability added.") : render(:new, status: :unprocessable_entity)
  end

  def edit
    @slot = current_user.provider_profile.availability_slots.find(params[:id])
  end

  def update
    @slot = current_user.provider_profile.availability_slots.find(params[:id])
    @slot.update(slot_params) ? redirect_to(availability_slots_path, notice: "Availability updated.") : render(:edit, status: :unprocessable_entity)
  end
  def destroy
    current_user.provider_profile.availability_slots.find(params[:id]).destroy; redirect_to availability_slots_path, notice: "Availability removed."
  end

  private
  def slot_params
    params.require(:availability_slot).permit(:day_of_week, :starts_at, :ends_at)
  end
end
