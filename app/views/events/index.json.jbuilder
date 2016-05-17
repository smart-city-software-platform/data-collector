json.array!(@events) do |event|
  json.extract! event, :id, :category, :resource_id, :date, :detail
end
