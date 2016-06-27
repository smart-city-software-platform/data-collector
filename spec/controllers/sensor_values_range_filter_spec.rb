require 'rails_helper'

RSpec.describe SensorValuesController, type: :controller do

  context 'Verify request with filters' do

    before :each do
      status_opt = 'on'
      uuids_hash = {
        "2de545ae-841a-4e4a-b961-a43bb324a2b9": {
            'temperature': [
              { 'value': '18.5',
                'date': '2016-03-01 09:00:00'},
              { 'value': '22.15',
                'date': '2016-03-01 10:00:00'},
              { 'value': '27',
                'date': '2016-03-02 08:00:00'},
              { 'value': '19.5',
                'date': '2016-03-03 07:00:00'},
            ],
            'humidity': [
              { 'value': '68',
                'date': '2016-03-01 09:00:00'},
              { 'value': '72',
                'date': '2016-03-01 10:00:00'},
              { 'value': '87',
                'date': '2016-03-02 08:00:00'},
              { 'value': '50',
                'date': '2016-03-03 07:00:00'},
            ]
        },
        "8fcbba32-ea98-4a84-9abf-c97c9c65c3c4": {},
        "989e93f2-35e1-4a2b-b80a-4bf91030085c": {
            'people': [
              { 'value': '70',
                'date': '2016-03-01 09:01:00'},
              { 'value': '11',
                'date': '2016-03-01 10:01:00'},
              { 'value': '22',
                'date': '2016-03-02 08:01:00'},
              { 'value': '40',
                'date': '2016-03-03 07:01:00'}
            ],
            'quality': [
              { 'value': '1',
                'date': '2016-03-01 09:30:00'},
              { 'value': '2',
                'date': '2016-03-01 10:30:00'},
              { 'value': '7',
                'date': '2016-03-02 08:30:00'},
              { 'value': '5',
                'date': '2016-03-03 07:30:00'}
            ]
        },
        "a9f4d13b-1c10-474c-9754-a0a92adcc72d": {
            'temperature': [
              { 'value': '28.5',
                'date': '2016-03-01 09:00:00'},
              { 'value': '29.5',
                'date': '2016-03-03 07:00:00'}
            ],
            'pressure': [
              { 'value': '1038',
                'date': '2016-03-01 09:00:00'},
              { 'value': '1012',
                'date': '2016-03-03 07:00:00'}
            ],
            'humidity': [
              { 'value': '70',
                'date': '2016-03-01 09:30:00'},
              { 'value': '72',
                'date': '2016-03-01 10:30:00'},
              { 'value': '67',
                'date': '2016-03-02 08:30:00'},
              { 'value': '75',
                'date': '2016-03-03 07:30:00'}
            ],
            'people': [
              { 'value': '70',
                'date': '2016-03-01 09:30:00'},
              { 'value': '0',
                'date': '2016-03-01 10:30:00'},
              { 'value': '22',
                'date': '2016-03-02 08:30:00'},
              { 'value': '40',
                'date': '2016-03-03 07:30:00'}
            ]
        }
      }
      # Creating data on database
      uuids_hash.each do |uuid, capability_hash|
        uri = "/basic_resources/1/components/" +
              "#{Faker::Number.between(1, 10)}/collect"
        resource = PlatformResource.create!(uuid: uuid,
                            uri: uri,
                            status: status_opt,
                            collect_interval: Faker::Number.between(60, 1000))

        # Create capabilities
        capability_hash.each do |capability_name, values_list|
          capability = Capability.find_or_create_by(name: capability_name)
          resource.capabilities << capability

          values_list.each do |value_hash|
            SensorValue.create!(capability: capability,
                          platform_resource: resource,
                          date: Time.parse(value_hash[:date]),
                          value: value_hash[:value] )
          end
        end
      end
    end

    context 'Request resources_data with range values' do

      it 'Correct response' do
        post 'resources_data', params: {sensor_value: 
                                   {range: {pressure: {min: 0, max: 22}}}}
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
      end

      it 'Correct list of capabilities for range with existing capability' do
        post 'resources_data', params: {sensor_value: 
                                   {range: {temperature: {min: 0, max: 100}}}}
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource.map(&Proc.new {|element|
                                                          element['uuid']} )

        expect(retrieved_uuids.empty?).to be_falsy
        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by_uuid(uuid)
          real_capabilities = platform.capabilities.pluck(:name)
          retrieved_capabilities = retrieved_resource.select do |element|
            element['uuid'] == uuid
          end.first['capabilities'].keys

          expect(real_capabilities).to include(*retrieved_capabilities)
          expect(['temperature']).to match_array(retrieved_capabilities)
        end
      end

      it 'Correct return for range with inexistent capability' do
        post 'resources_data', params: {sensor_value: 
                                   {range: {wontfindnocap: {min: 0, max: 22}}}}
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource.map(&Proc.new {|element|
                                                          element['uuid']} )

        expect(retrieved_uuids.size).to eq(0)
      end


      it 'Empty list for conflicting multiple capabilities' do
        post 'resources_data', params: {sensor_value: 
                                   {range: {
                                        temperature: {min: 0, max: 100},
                                        quality: {min: 0, max: 100} }}}
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource.map(&Proc.new {|element|
                                                          element['uuid']} )

        expect(retrieved_uuids.size).to eq(3)
      end

      it 'Correct list of capabilities for range multiple capabilities' do
        post 'resources_data', params: {sensor_value: 
                                   {range: {
                                        temperature: {min: 1, max: 101},
                                        humidity: {min: 2, max: 102} }}}
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource.map(&Proc.new {|element|
                                                          element['uuid']} )

        # TODO: is retrieving empty because concatenation of ranges
        # instead, the filter should use keyword "IN"
        expect(retrieved_uuids.empty?).to be_falsy
        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by_uuid(uuid)
          real_capabilities = platform.capabilities.pluck(:name)
          retrieved_capabilities = retrieved_resource.select do |element|
            element['uuid'] == uuid
          end.first['capabilities'].keys

          expect(real_capabilities).to include(*retrieved_capabilities)
          expect(['temperature', 'humidity']).to match_array(retrieved_capabilities)
        end
      end

    end

  end

end