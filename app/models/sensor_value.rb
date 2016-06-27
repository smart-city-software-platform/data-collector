class SensorValue < ApplicationRecord

  belongs_to :capability
  belongs_to :platform_resource

  validates :value, :date, :capability, :platform_resource, presence: true

  before_save :parse_to_float

  private
    def parse_to_float
      self.f_value = self.value.to_f if self.value.is_float? rescue nil
    end

end
