class Datum < ApplicationRecord
  belongs_to :event, dependent: :destroy
end
