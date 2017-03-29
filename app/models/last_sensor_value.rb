class LastSensorValue < ApplicationRecord
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

  private
    def parse_to_float
      self.f_value = self.value.to_f if self.value.is_float? rescue nil
    end
end
