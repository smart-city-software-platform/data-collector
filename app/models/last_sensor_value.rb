class LastSensorValue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :date, type: DateTime
  field :capability, type: String
  field :uuid, type: String

  belongs_to :platform_resource

  validates :date, :capability, :platform_resource, presence: true

  before_save :parse_to_float

  private
    def parse_to_float
      self.f_value = self.value.to_f if self.value.is_float? rescue nil
    end
end
