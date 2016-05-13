class Detail < ApplicationRecord
  belongs_to :event, dependent: :destroy
end
