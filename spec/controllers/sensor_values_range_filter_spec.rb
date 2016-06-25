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

    context 'Verify request with range values' do

      it 'Correct response' do
        post 'resources_data', params: {sensor_value: {range: {temperature: {min: 0, max: 22}}}}
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
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
      post 'resources_data_last', :format => :json
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
      post 'resource_data_last', params: { uuid: sensor_value_default.platform_resource.uuid }, :format => :json
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

  end
  
  def do_wrong_date_filter(route, use_uuid)
    err_data = ['foobar', 9.68]

    err_data.each do |data|
      params = { uuid: sensor_value_default.platform_resource.uuid, start_range: data, end_range: data}
      params.except!(:uuid) unless use_uuid

      post route, params: params
      expect(response.status).to eq(400)
    end
  end

  def do_range_value_filter(route, use_uuid)
    params = { uuid: sensor_value_default.platform_resource.uuid,
              range: {'temperature': {'min': 20, 'max': 70}} }
    post route, params: params
    expect(response.status).to eq(200)
    expect(response.body).to_not be_nil
    expect(response.body.empty?).to be_falsy
    expect(response.content_type).to eq('application/json')
  end

  def do_equal_value_filter(route, use_uuid, value)
    params = { uuid: sensor_value_default.platform_resource.uuid,
              range: {'temperature': {'equal': value} } }
    post route, params: params
    expect(response.status).to eq(200)
    expect(response.body).to_not be_nil
    expect(response.body.empty?).to be_falsy
    expect(response.content_type).to eq('application/json')
  end

end
