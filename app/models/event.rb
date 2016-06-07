class Event < ApplicationRecord
  has_many :detail

  validates :resource_uuid, :date, :presence => true

  after_create :send_notification 

  def send_notification
    broadcast("/events/listen", self)
  end
end
