json.array!(@details) do |detail|
  json.extract! detail, :id, :component_uuid, :capability, :data_type, :unit,
                        :value, :event_id
end
