require "rails_helper"

RSpec.describe EventsController, :type => :controller do
  
  let(:event) { create(:event) }

  describe "GET index/show" do
    before :each do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    it "assigns @events" do
      get :index
      expect(assigns(:events)).to eq([event])
    end

    it "renders the events index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "renders the event show template" do
      get :show, :id => event.id
      expect(response).to render_template("show")
    end

    it "has a 200 status code" do
      get :index
      expect(response.status).to eq(200)
    end

    it "has a 200 status code" do
      get :show, :id => event.id
      expect(response.status).to eq(200)
    end

    it "has a 400 status code" do
      get :show, :id => -5
      expect(response.status).to eq(400)
    end

  end

  describe "GET index/show to json" do
    before :each do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    it "returns a json object array" do
      get :index
      expect(response.content_type).to eq("application/json")
    end

    it "returns a json object " do
      get :show, :id => event.id
      expect(response.content_type).to eq("application/json")

      expect(response).to render_template(:show)
    end
  end
end