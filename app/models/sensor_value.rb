# frozen_string_literal: true
class SensorValue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :date, type: DateTime
  field :capability, type: String
  field :uuid, type: String

  belongs_to :platform_resource

  validates :date, :capability, :platform_resource, presence: true

  before_create :save_last_value

  private

  def save_last_value
    sensor_last = LastSensorValue.find_or_create_by(
      capability: self.capability,
      platform_resource_id: self.platform_resource_id,
      uuid: self.uuid
    )
    new_attributes = self.attributes.except("create_at", "update_at", "capability", "platform_resource_id", "uuid", "_id")
    new_attributes.each {|attribute, value| sensor_last.process_attribute(attribute, value)}
    sensor_last.save!
  end

end
