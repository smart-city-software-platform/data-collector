json.array!(@events) do |event|
  json.extract! event, :id, :category, :resource_id, :date, :detail
  json.url event_url(event, format: :json)
end
