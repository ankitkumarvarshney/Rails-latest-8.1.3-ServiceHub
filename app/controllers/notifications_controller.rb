class NotificationsController < ApplicationController
  before_action :require_login
  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "Notifications marked as read."
  end
end
