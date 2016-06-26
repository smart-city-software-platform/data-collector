class SensorValue < ApplicationRecord

  belongs_to :capability
  belongs_to :platform_resource

  validates :value, :date, :capability, :platform_resource, presence: true

  def to_f
    self.value.to_f if self.value.is_float? rescue nil
  end
end
