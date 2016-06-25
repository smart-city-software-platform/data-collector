require 'rails_helper'

RSpec.describe SensorValuesController, type: :controller do

  let(:sensor_value_default) { create(:default_sensor_value) }

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  it 'Has a valid factory' do
    expect(sensor_value_default).to be_valid
  end

  RSpec.shared_examples 'check http status' do |description, target, status|
    it ": #{description}" do
      post target
      expect(response).to have_http_status(status)
    end
  end

  context 'POST resources/data' do

    before :each do
      generate_data(4)
    end

    message = 'Simple request to resource_data, expect success'
    include_examples 'check http status', message, 'resources_data', :success

    message = 'returns a 200 status code when accessing normally'
    include_examples 'check http status', message, 'resources_data', 200

    it 'returns a json object array' do
      post 'resources_data'
      expect(response.content_type).to eq('application/json')
    end

    it 'renders the correct json and completes the url route' do
      post 'resources_data', format: :json
      expect(response.status).to eq(200)
      expect(response.body).to_not be_nil
      expect(response.body.empty?).to be_falsy
      expect(response.content_type).to eq('application/json')
    end

    it 'filters by capabilities values range' do
      do_range_value_filter('resources_data', false)
    end

    it 'filters by capabilities equal value' do
      do_equal_value_filter('resources_data', false, sensor_value_default.value)
    end

    it 'Returns a 400 status code when sending invalid data ranges argunments' do
      do_wrong_date_filter('resources_data', false)
    end

    it "fails when sending invalid pagination arguments" do
      do_wrong_pagination_filter('resources_data', false)
    end

    context 'Verify request with uuid : ' do

      it 'Correct response, using only one uuid inside Array' do
        post 'resources_data', params: {sensor_value: {uuids: [@uuids[0]]}}
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
      end

      it 'Correct response, using more than one uuid inside Array' do
        post 'resources_data', params: {sensor_value: {uuids: @uuids}}
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
      end

      it 'Correct return of single uuid' do
        post 'resources_data', params: {sensor_value: {uuids: [@uuids[0]]}}
        returned_json = JSON.parse(response.body)

        retrieved_resource = returned_json['resources']
        expect(retrieved_resource.size).to eq(1)
        uuid = retrieved_resource.first['uuid']
        expect(uuid).to eq(@uuids[0])
      end

      it 'Correct return of multiple uuids' do
        post 'resources_data', params: {sensor_value: {uuids: @uuids}}
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']

        expect(retrieved_resource.size).to eq(@uuids.size)

        uuids = retrieved_resource.map(&Proc.new {|element| element['uuid']} )
        expect(uuids).to match_array(@uuids)
      end

      it 'Correct list of capabilities for one uuid' do
        post 'resources_data', params: {sensor_value: {uuids: [@uuids[0]]}}
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']
        json_capabilities = retrieved_resource.first['capabilities']

        platform = PlatformResource.find_by_uuid(@uuids[0])
        real_capabilities = platform.capabilities.pluck(:name)
        retrieved_capabilities = json_capabilities.keys

        expect(real_capabilities).to match_array(retrieved_capabilities)
      end

      it 'Correct list of capabilities for multiple uuids' do
        post 'resources_data', params: {sensor_value: {uuids: @uuids}}
        returned_json = JSON.parse(response.body)
        retrieved_resource = returned_json['resources']

        @uuids.each do |uuid|
          platform = PlatformResource.find_by_uuid(uuid)
          real_capabilities = platform.capabilities.pluck(:name)
          find_capabilities = Proc.new do |element|
          end

          retrieved_capabilities = retrieved_resource.select do |element|
            element['uuid'] == uuid
          end.first['capabilities'].keys

          expect(real_capabilities).to match_array(retrieved_capabilities)
        end
      end

      it 'Correct returned sensors values with one uuid' do
        post 'resources_data', params: {sensor_value: {uuids: [@uuids[0]]}}
        returned_json = JSON.parse(response.body)

        retrieved_resource = returned_json['resources']
        json_capabilities = retrieved_resource.first['capabilities']

        platform = PlatformResource.find_by_uuid(@uuids[0])
        platform.capabilities.each do |cap|
          sensor_values = SensorValue.where(capability_id: cap.id,
                              platform_resource_id: platform.id).pluck(:value)
          retrieved_values = []
          json_capabilities[cap.name].each do |capability|
            retrieved_values << capability['value']
          end
          expect(sensor_values).to match_array(retrieved_values)
        end
      end

      it 'Correct returned sensors values with multiple uuids' do
        post 'resources_data', params: {sensor_value: {uuids: @uuids[0]}}
        returned_json = JSON.parse(response.body)

        retrieved_resource = returned_json['resources']

        @uuids.each do |uuid|
          platform = PlatformResource.find_by_uuid(uuid)

          json_capabilities = retrieved_resource.select{|element|
                              element['uuid'] == uuid}.first['capabilities']

          platform.capabilities.each do |cap|
            sensor_values = SensorValue.where(capability_id: cap.id,
                                platform_resource_id: platform.id).pluck(:value)
            retrieved_values = []
            json_capabilities[cap.name].each do |capability|
              retrieved_values << capability['value']
            end
            expect(sensor_values).to match_array(retrieved_values)
          end
        end
      end

    end
  end

  describe 'POST resources/:uuid/data' do
    it 'returns http success' do
      post 'resource_data', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response.status).to eq(200)
    end

    it 'returns a 200 status code when accessing normally' do
      post 'resource_data', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response.status).to eq(200)
    end

    it 'returns a json object array' do
      post 'resource_data', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response.content_type).to eq('application/json')
    end

    it 'renders the correct json and completes the url route' do
      post 'resource_data', params: { uuid: sensor_value_default.platform_resource.uuid }, :format => :json
      expect(response.status).to eq(200)
      expect(response.body).to_not be_nil
      expect(response.body.empty?).to be_falsy
      expect(response.content_type).to eq("application/json")
    end

    it 'returns a 404 status code when sending an invalid resource uuid' do
      invalid_uuids = [-5, 2.3, 'foobar']

      invalid_uuids.each do |uuid|
        post 'resource_data', params: { uuid: uuid }
        expect(response.status).to eq(404)
      end
    end

    it 'returns a 400 status code when sending invalid data ranges argunments' do
      do_wrong_date_filter('resource_data', true)
    end

    it 'filters by capabilities values range' do
      do_range_value_filter('resource_data', true)
    end

    it 'filters by capabilities equal value' do
      do_equal_value_filter('resource_data', true, sensor_value_default.value)
    end

    it "fails when sending invalid pagination arguments" do
      do_wrong_pagination_filter('resource_data', true)
    end

  end

  describe 'POST resources/data/last' do
    it 'returns http success' do
      post 'resources_data_last'
      expect(response).to have_http_status(:success)
    end

    it "returns a 200 status code when accessing normally" do
      post 'resources_data_last'
      expect(response.status).to eq(200)
    end

    it "returns a json object array" do
      post 'resources_data_last'
      expect(response.content_type).to eq("application/json")
    end

    it 'renders the correct json and completes the url route' do
      post 'resources_data_last'
      expect(response.status).to eq(200)
      expect(response.body).to_not be_nil
      expect(response.body.empty?).to be_falsy
      expect(response.content_type).to eq("application/json")
    end

    it 'returns a 400 status code when sending invalid data ranges argunments' do
      do_wrong_date_filter('resources_data_last', false)
    end

    it 'filters by capabilities values range' do
      do_range_value_filter('resources_data_last', false)
    end

    it 'filters by capabilities equal value' do
      do_equal_value_filter('resources_data_last', false, sensor_value_default.value)
    end

    it "fails when sending invalid pagination arguments" do
      do_wrong_pagination_filter('resources_data_last', false)
    end

  end

  describe 'POST resources/:uuid/data/last' do
    it 'returns http success' do
      post 'resource_data_last', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response).to have_http_status(:success)
    end

    it 'returns a 200 status code when accessing normally' do
      post 'resource_data_last', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response.status).to eq(200)
    end

    it 'returns a json object array' do
      post 'resource_data_last', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response.content_type).to eq("application/json")
    end

    it 'renders the correct json and completes the url route' do
      post 'resource_data_last', params: { uuid: sensor_value_default.platform_resource.uuid },
                                  format: :json
      expect(response.status).to eq(200)
      expect(response.body).to_not be_nil
      expect(response.body.empty?).to be_falsy
      expect(response.content_type).to eq('application/json')
    end

    it 'returns a 404 status code when sending an invalid resource uuid' do
      invalid_uuids = [-5, 2.3, 'foobar']

      invalid_uuids.each do |uuid|
        post 'resource_data_last', params: { uuid: uuid }
        expect(response.status).to eq(404)
      end
    end

    it 'Returns a 400 status code when sending invalid data ranges argunments' do
      do_wrong_date_filter('resource_data_last', true)
    end

    it 'filters by capabilities values range' do
      do_range_value_filter('resource_data_last', true)
    end

    it 'filters by capabilities equal value' do
      do_equal_value_filter('resource_data_last', true, sensor_value_default.value)
    end

    it "fails when sending invalid pagination arguments" do
      do_wrong_pagination_filter('resource_data_last', true)
    end

  end

  describe 'Stressing the pagination limits' do
    it "returns no more than the 'limit' resources" do
      generate_data(1005)
      # pass through all routes
      do_exceed_limit_pagination_filter('resources_data', false)
      do_exceed_limit_pagination_filter('resource_data', true)
      do_exceed_limit_pagination_filter('resources_data_last', false)
      do_exceed_limit_pagination_filter('resource_data_last', true)
    end
  end

  def do_wrong_date_filter(route, use_uuid)
    err_data = ['foobar', 9.68]

    err_data.each do |data|
      params = {uuid: sensor_value_default.platform_resource.uuid,
                start_range: data, end_range: data}
      params.except!(:uuid) unless use_uuid

      post route, params: params
      expect(response.status).to eq(400)
    end
  end

  def do_range_value_filter(route, use_uuid)
    params = {uuid: sensor_value_default.platform_resource.uuid,
              range: {'temperature': {'min': 20, 'max': 70}} }
    post route, params: params
    expect(response.status).to eq(200)
    expect(response.body).to_not be_nil
    expect(response.body.empty?).to be_falsy
    expect(response.content_type).to eq('application/json')
  end

  def do_equal_value_filter(route, use_uuid, value)
    params = {uuid: sensor_value_default.platform_resource.uuid,
              range: {'temperature': {'equal': value} } }
    post route, params: params
    expect(response.status).to eq(200)
    expect(response.body).to_not be_nil
    expect(response.body.empty?).to be_falsy
    expect(response.content_type).to eq('application/json')
  end

  def do_wrong_pagination_filter(route, use_uuid)
    foo_limits = [-1, 1.23, "foobar"]
    foo_starts = [-4, 9.87, "barfoo"]

    # Expect errors with all combinations of invalid arguments
    foo_limits.each do |limit|
      params = {uuid: sensor_value_default.platform_resource.uuid, limit: limit}
      params.except!(:uuid) unless use_uuid

      post route, params: params
      expect(response.status).to eq(400)
      params.except!(:limit)

      foo_starts.each do |start|
        params[:start] = start
        post route, params: params
        expect(response.status).to eq(400)

        params[:limit] = limit
        post route, params: params
        expect(response.status).to eq(400)
      end
    end    
  end

  def do_exceed_limit_pagination_filter(route, use_uuid)
    # the number of resources must not exceeds the limit
    limit = 1000
    params = {uuid: sensor_value_default.platform_resource.uuid, limit: limit + 1}
    params.except!(:uuid) unless use_uuid

    post route, params: params
    expect(response.status).to eq(200)
    expect(response.body).to_not be_nil
    expect(response.body.empty?).to be_falsy

    returned_json = JSON.parse(response.body)
    retrieved_resource = returned_json['resources']

    expect(retrieved_resource.size).to be <= (limit)
  end

  def generate_data(total)
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

end
