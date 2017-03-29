# frozen_string_literal: true
class PlatformResource < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri, type: String
  field :uuid, type: String
  field :status, type: String
  field :capabilities, type: Array

  has_many :sensor_values

  validates :uuid, :status, presence: true
end
