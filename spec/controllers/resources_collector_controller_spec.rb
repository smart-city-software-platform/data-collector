require 'rails_helper'

describe ResourcesCollectorController, :type => :controller do

  subject {response}
  let(:json) {JSON.parse(response.body)}

  before :each do
    event_params = FactoryGirl.attributes_for(:event)
    post :create, params: {resources_collector: event_params}
  end

  it 'has a valid factory' do
    expect(FactoryGirl.create(:event)).to be_valid
  end

  context 'verify create method' do

    it 'verify request ends successfully' do
      is_expected.to have_http_status(201)
    end

    it 'verify if request stored data' do
      event_params = {resource_id: 152, date: DateTime.now}
      expect{post :create, params: {resources_collector: event_params}}.
            to change(Event, :count).by(1)
    end

  end

  context 'verify update method' do
    it 'verify request ends successfully' do
      last_event = Event.last
      put :update, params: {id: last_event.id, resources_collector: {resource_id: 777}}
      is_expected.to have_http_status(200)
    end

    it 'verify if request updated data (check resource_id)' do
      last_event = Event.last
      put :update, params: {id: last_event.id, resources_collector: {resource_id: 777}}
      last_event = Event.last
      expect(last_event.resource_id).to eq(777)
    end

    it 'verify if request updated data (check date)' do
      last_event = Event.last
      date = DateTime.now
      put :update, params: {id: last_event.id, resources_collector: {date: date.to_s}}
      last_event = Event.last
      expect(last_event.date).to eq(date.to_s)
    end

  end

  after :each do
    event_params = nil
  end

end
