json.array!(@events) do |event|
  json.extract! event, :id, :resource_id, :date, :detail
end
