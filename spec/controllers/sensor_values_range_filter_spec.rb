# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SensorValuesController, type: :controller do
  context 'Verify request with filters' do
    before :each do
      status_opt = 'on'
      uuids_hash = {
        '2de545ae-841a-4e4a-b961-a43bb324a2b9': {
          'temperature': [
            { 'temperature': '18.5',
              'date': '2016-03-01 09:00:00' },
            { 'temperature': '22.15',
              'date': '2016-03-01 10:00:00' },
            { 'temperature': '27',
              'date': '2016-03-02 08:00:00' },
            { 'temperature': '19.5',
              'date': '2016-03-03 07:00:00' }
          ],
          'humidity': [
            { 'humidity': '68',
              'date': '2016-03-01 09:00:00' },
            { 'humidity': '72',
              'date': '2016-03-01 10:00:00' },
            { 'humidity': '87',
              'date': '2016-03-02 08:00:00' },
            { 'humidity': '50',
              'date': '2016-03-03 07:00:00' }
          ]
        },
        '8fcbba32-ea98-4a84-9abf-c97c9c65c3c4': {},
        '989e93f2-35e1-4a2b-b80a-4bf91030085c': {
          'people': [
            { 'name': 'Thomas S. Seibel',
              'age': '18',
              'date': '2016-03-01 09:01:00' },
            { 'name': 'Jose R. Garcia',
              'age': '17',
              'date': '2016-03-01 10:01:00' },
            { 'name': 'Débora M. Wright',
              'age': '26',
              'date': '2016-03-02 08:01:00' },
            { 'name': 'Jose J. Whetsel',
              'age': '55',
              'date': '2016-03-03 07:01:00'}
          ],
          'quality': [
            { 'quality': '1',
              'date': '2016-03-01 09:30:00' },
            { 'quality': '2',
              'date': '2016-03-01 10:30:00' },
            { 'quality': '7',
              'date': '2016-03-02 08:30:00' },
            { 'quality': '5',
              'date': '2016-03-03 07:30:00' }
          ]
        },
        'a9f4d13b-1c10-474c-9754-a0a92adcc72d': {
          'temperature': [
            { 'temperature': '28.5',
              'date': '2016-03-01 09:00:00' },
            { 'temperature': '29.5',
              'date': '2016-03-03 07:00:00' }
          ],
          'pressure': [
            { 'pressure': '1038',
              'date': '2016-03-01 09:00:00' },
            { 'pressure': '1012',
              'date': '2016-03-03 07:00:00' }
          ],
          'humidity': [
            { 'humidity': '70',
              'date': '2016-03-01 09:30:00' },
            { 'humidity': '72',
              'date': '2016-03-01 10:30:00' },
            { 'humidity': '67',
              'date': '2016-03-02 08:30:00' },
            { 'humidity': '75',
              'date': '2016-03-03 07:30:00' }
          ],
          'people': [
            { 'name': 'Robert M. Celentano',
              'age': 45,
              'date': '2016-03-01 09:30:00' },
            { 'name': 'Kelly N. Bean',
              'age': 35,
              'date': '2016-03-01 10:30:00' },
            { 'name': 'Mary K. Hickey',
              'age': 25,
              'date': '2016-03-02 08:30:00' },
            { 'name': 'William N. Florence',
              'age': 17,
              'date': '2016-03-03 07:30:00' }
          ]
        }
      }
      # Creating data on database
      uuids_hash.each do |uuid, capability_hash|
        uri = '/basic_resources/1/components/' \
              '#{Faker::Number.between(1, 10)}/collect'
        resource = PlatformResource.create!(uuid: uuid,
                                            uri: uri,
                                            status: status_opt,
                                            collect_interval: Faker::Number
                                            .between(60, 1000))

        # Create capabilities
        capability_hash.each do |capability_name, values_list|
          capability = capability_name
          resource.capabilities << capability.to_s
          resource.save!

          values_list.each do |value_hash|
            fields = {
              capability: capability,
              platform_resource_id: resource.id,
            }
            fields.merge!(value_hash)
            SensorValue.create!(fields)
          end
        end
      end
    end

    context 'Request resources_data with range values' do
      it 'Correct response' do
        post 'resources_data',
              params: {
                sensor_value: {
                  range: {
                    pressure: { pressure: { min: 0, max: 22 } }
                  }
                }
              }
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
      end

      it 'Correct list of capabilities for range with existing capability' do
        post 'resources_data',
              params: {
                sensor_value: {
                  range: {
                    temperature: { temperature: { min: 0, max: 100 } }
                  }
                }
              }
        retrieved_uuids, retrieved_resource = parse_response

        expect(retrieved_uuids.empty?).to be_falsy
        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by(uuid: uuid)
          real_capabilities = platform.capabilities
          retrieved_capabilities = retrieved_resource.select do |element|
            element['uuid'] == uuid
          end.first['capabilities'].keys

          expect(real_capabilities).to include(*retrieved_capabilities)
          expect(['temperature']).to match_array(retrieved_capabilities)
        end
      end

      it 'Correct return for range with inexistent capability' do
        post 'resources_data',
             params: {
                sensor_value: {
                  range: { wontfindnocap: { value: { min: 0, max: 22 } } }
                }
             }
        retrieved_uuids, = parse_response

        expect(retrieved_uuids.size).to eq(0)
      end

      it 'Correct return for multiple capabilities' do
        post 'resources_data',
             params: {
               sensor_value: {
                 range: {
                   temperature: { temperature: { min: 0, max: 100 } },
                   quality: { quality: { min: 0, max: 100 } }
                 }
               }
             }

        retrieved_uuids, = parse_response
        expect(retrieved_uuids.size).to eq(3)
      end

      it 'Empty list for invalid min/max params' do
        post 'resources_data',
             params: {
               sensor_value: {
                 range: {
                   temperature: { temperature: { min: 'Foo', max: 'Zeni' } },
                   quality: { quality: { max: 'Fakebook' } }
                 }
               }
             }

        retrieved_uuids, = parse_response
        expect(retrieved_uuids.size).to eq(0)
      end

      it 'Correct return only for the valid min/max params' do
        post 'resources_data',
             params: {
               sensor_value: {
                 range: {
                   temperature: { temperature: { min: 0, max: 100 } },
                   quality: { quality: { max: 'Foo' } }
                 }
               }
             }

        retrieved_uuids, = parse_response
        expect(retrieved_uuids.size).to eq(2)
      end

      it 'Correct return when used min/max and equal params simultaneously' do
        post 'resources_data',
             params: {
               sensor_value: {
                 range: {
                   pressure: { pressure: { min: 1000 } },
                   people: { name: { equal: 'Débora M. Wright'} }
                 }
               }
             }

        retrieved_uuids, = parse_response
        expect(retrieved_uuids.size).to eq(2)
      end

      it 'Correct list of capabilities for range multiple capabilities' do
        post 'resources_data',
             params: {
               sensor_value: {
                 range: {
                   temperature: { temperature: { min: 1, max: 101 } },
                   humidity: { humidity: { min: 2, max: 102 } }
                 }
               }
             }
        retrieved_uuids, retrieved_resource = parse_response

        expect(retrieved_uuids.empty?).to be_falsy
        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by(uuid: uuid)
          real_capabilities = platform.capabilities
          retrieved_capabilities = retrieved_resource.select do |element|
            element['uuid'] == uuid
          end.last['capabilities'].keys

          expect(real_capabilities).to include(*retrieved_capabilities)
          expect(%w(temperature humidity)).to match_array(retrieved_capabilities)
        end
      end

      def parse_response
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource
                          .map(&proc { |element| element['uuid'] })
        return retrieved_uuids, retrieved_resource
      end

      it 'Correct empty list for invalid range' do
        post 'resources_data',
             params: {
               sensor_value: {
                 range: {
                   temperature: { temperature: { min: 150, max: 160 } },
                   humidity: { humidity: { min: 130, max: 200 } }
                 }
               }
             }

        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']

        expect(retrieved_resource.empty?).to be_truthy
      end

      it 'Return correct list uuis between range values' do
        post 'resources_data',
             params: {
               sensor_value: {
                 range: {
                   temperature: { temperature: { min: 0, max: 170 } },
                   humidity: { humidity: { min: 2, max: 102 } }
                 }
               }
             }

        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource
                          .map(&proc { |element| element['uuid'] })

        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by(uuid: uuid)

          json_capabilities = retrieved_resource
                              .select { |element| element['uuid'] == uuid }
                              .first['capabilities']

          platform.capabilities.each do |cap|
            next unless json_capabilities.key? cap

            sensor_values =
              SensorValue.where(
                capability: cap, platform_resource_id: platform.id
              )
              .map(&proc{|obj| obj.dynamic_attributes})

            retrieved_values = []
            json_capabilities[cap].each do |capability|
              retrieved_values << capability
            end
            expect(sensor_values).to include(*retrieved_values)
          end
        end
      end

      it 'Correct return resources_data to equal value' do
        post 'resources_data',
             params: {
                sensor_value: {
                  range: {
                    temperature: { temperature: { equal: 29.5 } }
                  }
                }
             }
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource
                          .map(&proc { |element| element['uuid'] })

        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by(uuid: uuid)

          json_capabilities = retrieved_resource
                              .select { |element| element['uuid'] == uuid }
                              .first['capabilities']

          platform.capabilities.each do |cap|
            next unless json_capabilities.key? cap

            sensor_values =
              SensorValue.where(
                capability: cap, platform_resource_id: platform.id
              )
                         .map(&proc{|obj| obj.dynamic_attributes})

            retrieved_values = []
            json_capabilities[cap].each do |capability|
              retrieved_values << capability
            end
            expect(sensor_values).to include(*retrieved_values)
          end
        end
      end
    end

    context 'Request resources_data with no values' do
      it 'Correct response' do
        post 'resources_data',
             params: { sensor_value:
                     { capabilities: %w(temperature humidity) } }

        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
      end

      it 'Correct list of capabilities for multiple capabilities' do
        post 'resources_data',
             params: { sensor_value: { capabilities: %w(temperature people) } }

        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource
                          .map(&proc { |element| element['uuid'] })

        expect(retrieved_uuids.empty?).to be_falsy
        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by(uuid: uuid)
          real_capabilities = platform.capabilities
          retrieved_capabilities = retrieved_resource.select do |element|
            element['uuid'] == uuid
          end.first['capabilities'].keys

          expect(real_capabilities).to include(*retrieved_capabilities)
          expect(%w(temperature people)).to include(*retrieved_capabilities)
        end
      end
    end

    context 'Request resources_data with date values' do
      it 'Correct response' do
        post 'resources_data', params: { start_range: '2016-01-01 09:21:29',
                                         end_range: '2016-03-03 07:00:00' }

        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
      end

      it 'Request resources_data return empty' do
        post 'resources_data', params: { start_range: '2016-01-01 09:21:29',
                                         end_range: '2016-01-03 07:00:00' }

        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']

        expect(retrieved_resource.empty?).to be_truthy
      end

      it 'Correct return for range of date' do
        post 'resources_data', params: { start_range: '2016-02-01 01:03:43',
                                         end_range: '2016-06-25 16:03:43' }

        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource
                          .map(&proc { |element| element['uuid'] })

        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by(uuid: uuid)

          json_capabilities = retrieved_resource
                              .select { |element| element['uuid'] == uuid }
                              .first['capabilities']

          platform.capabilities.each do |cap|
            sensor_values_date =
              SensorValue.where(
                capability: cap, platform_resource_id: platform.id)
                         .pluck(:date)

            retrieved_values = []
            json_capabilities[cap].each do |capability|
              retrieved_values << capability['date']
            end
            expect(sensor_values_date).to include(*retrieved_values)
          end
        end
      end
    end
    context 'Verify POST resource data last' do
      it 'returns the last value for all uuids' do
        post 'resources_data_last'
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource
                          .map(&proc { |element| element['uuid'] })

        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by(uuid: uuid)

          json_capabilities = retrieved_resource
                              .select { |element| element['uuid'] == uuid }
                              .first['capabilities']

          platform.capabilities.each do |cap|
            last_values =
              LastSensorValue.where(
                capability: cap, platform_resource_id: platform.id
              )
                             .map(&proc{|obj| obj.dynamic_attributes.to_json})

            retrieved_values = []
            json_capabilities[cap].each do |capability|
              retrieved_values << capability.to_json
            end
            expect(last_values.size).to eq(1)
            expect(retrieved_values.size).to eq(1)
            expect(retrieved_values.first).to eq(last_values.first)
          end
        end
      end

      it 'returns the last value for one uuid' do
        post 'resource_data_last', params:
        { uuid: '2de545ae-841a-4e4a-b961-a43bb324a2b9' }
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource
                          .map(&proc { |element| element['uuid'] })
        expect(retrieved_uuids.size).to eq(1)
        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by(uuid: uuid)
          json_capabilities = retrieved_resource
                              .select { |element| element['uuid'] == uuid }
                              .first['capabilities']
          platform.capabilities.each do |cap|
            last_values =
              LastSensorValue.where(
                capability: cap, platform_resource_id: platform.id
              )
                             .map(&proc{|obj| obj.dynamic_attributes.to_json})

            retrieved_values = []
            json_capabilities[cap].each do |capability|
              retrieved_values << capability.to_json
            end
            expect(last_values.size).to eq(1)
            expect(retrieved_values.size).to eq(1)
            expect(retrieved_values.first).to eq(last_values.first)
          end
        end
      end

      it 'returns the last value for multiple uuids' do
        post 'resources_data_last', params: {
          sensor_value: {
            uuids: [
              '2de545ae-841a-4e4a-b961-a43bb324a2b9',
              '989e93f2-35e1-4a2b-b80a-4bf91030085c'
            ]
          }
        }
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        retrieved_uuids = retrieved_resource
                          .map(&proc { |element| element['uuid'] })
        expect(retrieved_uuids.size).to eq(2)
        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by(uuid: uuid)
          json_capabilities = retrieved_resource
                              .select { |element| element['uuid'] == uuid }
                              .first['capabilities']
          platform.capabilities.each do |cap|
            last_values =
              LastSensorValue.where(
                capability: cap, platform_resource_id: platform.id
              ).map(&proc{|obj| obj.dynamic_attributes.to_json})

            retrieved_values = []
            json_capabilities[cap].each do |capability|
              retrieved_values << capability.to_json
            end
            expect(last_values.size).to eq(1)
            expect(retrieved_values.size).to eq(1)
            expect(retrieved_values.first).to eq(last_values.first)
          end
        end
      end
    end

  end
end
