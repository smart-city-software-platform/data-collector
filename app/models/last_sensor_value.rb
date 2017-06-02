class LastSensorValue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :date, type: DateTime
  field :capability, type: String
  field :uuid, type: String

  belongs_to :platform_resource

  validates :date, :capability, :platform_resource, presence: true

  def self.static_attributes
    ["_id", "created_at", "updated_at", "capability", "uuid",
     "platform_resource_id"]
  end

  def dynamic_attributes
    self.attributes.except(*SensorValue.static_attributes)
  end
end
