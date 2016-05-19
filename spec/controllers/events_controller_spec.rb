require 'rails_helper'

describe EventsController, :type => :controller do
  
  let(:event) { create(:event) }

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  # /events
  describe "GET :index" do
    it "assigns @events" do
      get :index
      expect(assigns(:events)).to eq([event])
    end

    it "renders the events index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "returns a 200 status code when accessing normally" do
      get :index
      expect(response.status).to eq(200)
    end

    it "returns a 400 status code when sending invalid pagination arguments" do
      # Lists of invalid arguments
      err_limit = [-1, 1.23, "foobar"]
      err_start = [-4, 9.87, "barfoo"]

      err_limit.each do |limit|
        # Expect error with each 'limit'
        get :index, params: { limit: limit }
        expect(response.status).to eq(400)

        err_start.each do |start|
          # Expect error with each 'start'
          get :index, params: { start: start }
          expect(response.status).to eq(400)

          # Expect error with each 'limit' and 'start' combined
          get :index, params: { limit: limit, start: start }
          expect(response.status).to eq(400)
        end
      end
    end

  end

  describe "GET :index to json" do
    it "returns a json object array" do
      get :index
      expect(response.content_type).to eq("application/json")
    end
  end

  # /events/:event_id
  describe "GET :show" do
    it "renders the event show template" do
      get :show, params: { id: event.id }
      expect(response).to render_template("show")
    end

    it "returns a 200 status code when requesting correctly" do
      get :show, params: { id: event.id }
      expect(response.status).to eq(200)
    end

    it "returns a 400 status code when sending an invalid 'event_id'" do
      # List of invalid arguments
      err_ids = [-5, 2.3, "foobar"]

      err_ids.each do |id|
        get :show, params: { id: id }
        expect(response.status).to eq(400)
      end
    end
  end

  describe "GET :show to json" do
    it "returns a json object " do
      get :show, params: { id: event.id }
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
      it "renders the correct template and completes the url route" do
        get :index, :format => :json
        expect(response).to render_template(:index)
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
        expect(response.content_type).to eq("application/json")
      end

      it "filter the events by capability" do
        get :index, :format => :json, params: {capability: 'temperature'}
        expect(response).to render_template(:index)
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
      end
   end
  end

end
