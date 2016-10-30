# frozen_string_literal: true
class PlatformResource < ApplicationRecord
  has_many :platform_resource_capabilities
  has_many :capabilities, through: :platform_resource_capabilities
  has_many :sensor_values

  validates :uuid, :status, presence: true
end
