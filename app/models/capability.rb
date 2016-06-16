class Capability < ApplicationRecord

  has_many :platform_resource_capabilities
  has_many :platform_resources, through: :platform_resource_capabilities

  validates :name, :presence => true

end
