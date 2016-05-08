json.array!(@data) do |datum|
  json.extract! datum, :id, :component_uuid, :lat, :lon, :capability, :attribute, :type, :unity, :value
  json.url datum_url(datum, format: :json)
end
