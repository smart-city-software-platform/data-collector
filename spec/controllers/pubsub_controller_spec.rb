require 'rails_helper'

RSpec.describe PubsubController, type: :controller do

  describe "GET #demo" do
    it "returns http success" do
      get :demo
      expect(response).to have_http_status(:success)
    end
  end

end
