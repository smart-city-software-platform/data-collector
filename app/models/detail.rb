class Detail < ApplicationRecord
  belongs_to :event, dependent: :destroy

  validates :component_uuid, :event_id, :presence => true
  validate :disallow_empty_and_nil

  # Raises error if Detail has empty String or 'nil' as a value for any attribute
  def disallow_empty_and_nil
    if self.component_uuid.blank? || self.capability.blank? || self.data_type.blank?
       || self.unit.blank? || self.value.blank?
         self.errors.add :base, 'Cannot add empty String!'
    end
  end

end
