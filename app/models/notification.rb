class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true
  validates :title, :body, presence: true
  scope :unread, -> { where(read_at: nil) }
end
