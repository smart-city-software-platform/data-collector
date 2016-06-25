require 'rails_helper'

RSpec.describe SensorValuesController, type: :controller do

  context 'Verify request with filters' do

    before :each do
      total = 4
      status_opt = ['on', 'off', 'unknown', 'wtf']
      list_of_capabilities = ['no', 'temperature', 'humidity', 'pressure']
      @uuids = []

      # Creating data on database
      total.times do |index|
        @uuids.push(SecureRandom.uuid)
        uri = "/basic_resources/#{Faker::Number.between(1,10)}/components/" +
              "#{Faker::Number.between(1,10)}/collect"

        resource = PlatformResource.create!(uuid: @uuids[index],
                            uri: uri,
                            status: status_opt[rand(status_opt.size)],
                            collect_interval: Faker::Number.between(60, 1000))
        total_cap = Faker::Number.between(1,3)
        # Create capabilities
        total_cap.times do |index|
          capability = Capability.find_or_create_by(name: list_of_capabilities[index])
          resource.capabilities << capability

          2.times do |j|
            SensorValue.create!(capability: capability,
                          platform_resource: resource,
                          date: Faker::Time.between(DateTime.now - 1, DateTime.now),
                          value: Faker::Number.decimal(2, 3))
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
                                   {range: {pressure: {min: 0, max: 22}}}}
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        
        retrieved_uuids = retrieved_resource.map(&Proc.new {|element|
                                                          element['uuid']} )

        retrieved_uuids.each do |uuid|
          platform = PlatformResource.find_by_uuid(uuid)
          real_capabilities = platform.capabilities.pluck(:name)
          retrieved_capabilities = retrieved_resource.select do |element|
            element['uuid'] == uuid
          end.first['capabilities'].keys

          expect(real_capabilities).to include(*retrieved_capabilities)
          expect(['pressure']).to include(*retrieved_capabilities)
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

    end

  end
#     params = { uuid: sensor_value_default.platform_resource.uuid,
#               range: {'temperature': {'equal': value} } }
#     post route, params: params
#     expect(response.status).to eq(200)
#     expect(response.body).to_not be_nil
#     expect(response.body.empty?).to be_falsy
#     expect(response.content_type).to eq('application/json')
#   end

end
