class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :signed_in?, :provider?, :admin?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def signed_in? = current_user.present?
  def provider? = current_user&.provider?
  def admin? = current_user&.admin?

  def require_login
    redirect_to new_session_path, alert: "Please sign in to continue." unless signed_in?
  end

  def require_provider
    require_login and return unless signed_in?
    redirect_to root_path, alert: "Provider access is required." unless provider?
  end

  def require_admin
    require_login and return unless signed_in?
    redirect_to root_path, alert: "Administrator access is required." unless admin?
  end
end
