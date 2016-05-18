class Detail < ApplicationRecord
  belongs_to :event, dependent: :destroy

  validates :component_uuid, :event_id, :capability, :data_type, :unit, :value,
            :presence => true
end
