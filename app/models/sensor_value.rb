# frozen_string_literal: true
class SensorValue < ApplicationRecord
  belongs_to :capability
  belongs_to :platform_resource

  validates :value, :date, :capability, :platform_resource, presence: true

  before_save :parse_to_float
  before_create :save_last_value

  private

  def save_last_value
    sensor_last = LastSensorValue.find_or_create_by(capability_id: self.capability_id, platform_resource_id: self.platform_resource_id)
    sensor_last.value = self.value
    sensor_last.date = self.date
    sensor_last.save
  end

  def parse_to_float
    self.f_value = self.value.to_f if self.value.is_float? rescue nil
  end
end
