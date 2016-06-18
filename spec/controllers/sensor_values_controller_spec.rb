require 'rails_helper'

RSpec.describe SensorValuesController, type: :controller do

  let(:sensor_value_default) { create(:sensor_value) }

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe "POST resources/data" do
    it "returns http success" do
      post 'resources_data'
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST resources/data/last" do
    it "returns http success" do
      post 'resources_data_last'
      expect(response).to have_http_status(:success)
    end
  end

end
