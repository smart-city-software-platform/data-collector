class Detail < ApplicationRecord
  belongs_to :event, dependent: :destroy

  validates :component_uuid, :event_id, :presence => true
end
