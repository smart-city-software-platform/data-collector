class LastSensorValue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :date, type: DateTime
  field :capability, type: String
  field :uuid, type: String

  index({ uuid: 1 }, { name: "last_uuid_index" })
  index({ capability: 1 }, { name: "last_capability_index" })
  index({ uuid: 1, capability: 1 }, { name: "last_capability_uuid_index" })

  belongs_to :platform_resource

  validates :date, :capability, :platform_resource, presence: true

  def self.static_attributes
    ["_id", "created_at", "updated_at", "capability", "uuid",
     "platform_resource_id", "date"]
  end

  def dynamic_attributes
    self.attributes.except(*SensorValue.static_attributes)
  end
end
