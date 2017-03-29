# frozen_string_literal: true
class SensorValue < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps

  field :value, type: String
  field :f_value, type: Float
  field :date, type: DateTime
  field :capability, type: String
  field :uuid, type: String

  belongs_to :platform_resource

  validates :value, :date, :capability, :platform_resource, presence: true

  before_save :parse_to_float
  before_create :save_last_value

  private

  def save_last_value
    sensor_last = LastSensorValue.find_or_create_by(
      capability: self.capability,
      platform_resource_id: self.platform_resource_id,
      uuid: self.uuid
    )
    sensor_last.value = self.value
    sensor_last.date = self.date
    sensor_last.save
  end

  def parse_to_float
    self.f_value = self.value.to_f if self.value.is_float? rescue nil
  end
end
