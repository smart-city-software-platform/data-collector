class Event < ApplicationRecord
  has_many :detail

  validates :resource_id, :date, :presence => true
end
