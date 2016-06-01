json.array!(@events) do |event|
  json.extract! event, :id, :resource_uuid, :date, :detail
end
