require 'rails_helper'

describe DetailsController, :type => :controller do
  
  let(:event) { create(:event_with_details, details_count: 17) }

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  # GET /events/:event_id/details
  describe "GET :index" do
    it "assigns @details" do
      get :index, params: {event_id: event.id}
      expect(assigns(:details)).to eq(event.detail)
    end

    it "renders the details index template" do
      get :index, params: {event_id: event.id}
      expect(response).to render_template("index")
    end

    it "returns a 200 status code when accessing normally" do
      get :index, params: {event_id: event.id}
      expect(response.status).to eq(200)
    end
  end

  describe "GET :index to json" do
    it "returns a json object array" do
      get :index, params: {event_id: event.id}
      expect(response.content_type).to eq("application/json")
    end
  end

  # GET /events/:event_id/details/:detail_id
  describe "GET :show" do
    it "renders the detail show template" do
      get :show, params: { event_id: event.id, id: event.detail[0].id }
      expect(response).to render_template("show")
    end

    it "returns a 200 status code when requesting correctly" do
      get :show, params: { event_id: event.id, id: event.detail[0].id }
      expect(response.status).to eq(200)
    end

    it "returns a 400 status code when sending an invalid 'detail_id'" do
      # List of invalid arguments
      err_ids = [-5, 2.3, "foobar"]

      err_ids.each do |id|
        get :show, params: { event_id: event.id, id: id }
        expect(response.status).to eq(400)
      end
    end
  end

  describe "GET :show to json" do
    it "returns a json object " do
      get :show, params: { event_id: event.id, id: event.detail[0].id }
      expect(response.content_type).to eq("application/json")
    end
  end

  context "with render_views" do
    render_views

    before :each do
      headers = {
        "ACCEPT" => "application/json"
      }
    end

    describe "GET :index" do

      it "renders the correct json and completes the url route" do
        get :index, :format => :json, params: { event_id: event.id }
        expect(response).to render_template(:index)
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
        expect(response.content_type).to eq("application/json")
      end
    end

    describe "GET :show" do

      it "renders the correct json and completes the url route" do
        get :show, :format => :json,
            params: { event_id: event.id, id: event.detail[0].id }
        expect(response).to render_template(:show)
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
        expect(response.content_type).to eq("application/json")
      end
    end

  end
end
