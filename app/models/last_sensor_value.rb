class LastSensorValue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :date, type: DateTime
  field :capability, type: String
  field :uuid, type: String

  belongs_to :platform_resource

  validates :date, :capability, :platform_resource, presence: true
end
