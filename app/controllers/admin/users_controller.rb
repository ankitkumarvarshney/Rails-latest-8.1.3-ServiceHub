class Admin::UsersController < ApplicationController
  before_action :require_admin
  def index; @users = User.order(created_at: :desc); end
  def update; User.find(params[:id]).update!(role: params.require(:user)[:role]); redirect_to admin_users_path, notice: "Role updated."; end
end
