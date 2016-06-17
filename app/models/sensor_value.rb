class SensorValue < ApplicationRecord
  
  belongs_to :capability
  belongs_to :platform_resource

  validates :value, :date, :presence => true
end
