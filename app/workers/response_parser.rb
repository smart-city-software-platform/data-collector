require 'json'

# Resource-related fields
COMPONENTS = 'components'
LAST_COLLECTION = 'last_collection'
CAPABILITY_LABEL = 0
CAPABILITY_VALUE = 1

Event = Struct.new('Address',
                    :component_uuid,
                    :event_id,
                    :capability,
                    :data_type,
                    :unit,
                    :value)

def update_field(pElement, pEvent)
  pElement.each do |capability|
    if capability[CAPABILITY_LABEL] == pEvent.capability
      pEvent.value = capability[CAPABILITY_VALUE]
    end
  end
end

raw_data = File.read('input.txt')

begin
  resource_json = JSON.parse(raw_data)
rescue JSON::ParserError => exception
  puts 'problem to parse json'
end

if resource_json.key?COMPONENTS
  related = resource_json[COMPONENTS]
end

event = Event.new('uuid', '33', 'temperature', '344', '4', 'sfd')

related.each do |element|
  partial = element[LAST_COLLECTION]
  update_field(partial, event)
end

puts event.inspect
