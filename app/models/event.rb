class Event < ApplicationRecord
  has_many :detail

  validates :resource_id, :date, :presence => true
  validates_inclusion_of :category, in: ['pull', 'push']
end
