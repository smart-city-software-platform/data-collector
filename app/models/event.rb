class Event < ApplicationRecord
  has_many :detail

  validates :resource_uuid, :date, :presence => true

end
