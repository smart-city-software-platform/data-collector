require 'rails_helper'

RSpec.describe SensorValuesController, type: :controller do

  let(:sensor_value_default) { create(:sensor_value) }

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  it 'Has a valid factory' do
    expect(sensor_value_default).to be_valid
  end

  describe "POST resources/data" do
    it "returns http success" do
      post 'resources_data'
      expect(response).to have_http_status(:success)
    end

    #it "assigns @sensor_values" do
    #  post 'resources_data'
    #  expect(assigns(:sensor_values)).to eq([sensor_value_default])
    #end

    it "returns a 200 status code when accessing normally" do
      get 'resources_data'
      expect(response.status).to eq(200)
    end

    it "returns a json object array" do
      get 'resources_data'
      expect(response.content_type).to eq("application/json")
    end

    it "renders the correct json and completes the url route" do
      post 'resources_data', :format => :json
      expect(response.status).to eq(200)
      expect(response.body).to_not be_nil
      expect(response.body.empty?).to be_falsy
      expect(response.content_type).to eq("application/json")
    end

  end

  describe "POST resources/:uuid/data" do
    it "returns http success" do
      post 'resource_data', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response).to have_http_status(:success)
    end

    it "returns a 200 status code when accessing normally" do
      post 'resource_data', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response.status).to eq(200)
    end

    it "returns a json object array" do
      post 'resource_data', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response.content_type).to eq("application/json")
    end

    it "renders the correct json and completes the url route" do
      post 'resource_data', params: { uuid: sensor_value_default.platform_resource.uuid }, :format => :json
      expect(response.status).to eq(200)
      expect(response.body).to_not be_nil
      expect(response.body.empty?).to be_falsy
      expect(response.content_type).to eq("application/json")
    end

  end

  describe "POST resources/data/last" do
    it "returns http success" do
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

    it "renders the correct json and completes the url route" do
      post 'resources_data_last', :format => :json
      expect(response.status).to eq(200)
      expect(response.body).to_not be_nil
      expect(response.body.empty?).to be_falsy
      expect(response.content_type).to eq("application/json")
    end
  end

  describe "POST resources/:uuid/data/last" do
    it "returns http success" do
      post 'resource_data_last', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response).to have_http_status(:success)
    end

    it "returns a 200 status code when accessing normally" do
      post 'resource_data_last', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response.status).to eq(200)
    end

    it "returns a json object array" do
      post 'resource_data_last', params: { uuid: sensor_value_default.platform_resource.uuid }
      expect(response.content_type).to eq("application/json")
    end

    it "renders the correct json and completes the url route" do
      post 'resource_data_last', params: { uuid: sensor_value_default.platform_resource.uuid }, :format => :json
      expect(response.status).to eq(200)
      expect(response.body).to_not be_nil
      expect(response.body.empty?).to be_falsy
      expect(response.content_type).to eq("application/json")
    end
  end

end
