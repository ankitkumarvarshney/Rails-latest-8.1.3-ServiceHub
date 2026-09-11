class UpcomingBookingReminderJob < ApplicationJob
  def perform
    Booking.confirmed.where(start_time: 23.hours.from_now..25.hours.from_now).find_each do |booking|
      next if booking.user.notifications.where(notifiable: booking, title: "Appointment reminder").exists?

      Notification.create!(
        user: booking.user,
        notifiable: booking,
        title: "Appointment reminder",
        body: "Reminder: #{booking.service.name} is tomorrow at #{I18n.l(booking.start_time, format: :short)}."
      )
    end
  end
end
