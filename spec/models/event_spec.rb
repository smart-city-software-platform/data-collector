require 'rails_helper'

describe Event, :type => :model do

  let(:event) { create(:event) }

  it "has a valid factory" do
    expect(event).to be_valid
  end

  it "has a date of occurence" do
    expect(event.date).should_not be_nil
    expect(event.date).should_not eq('')
    FactoryGirl.build(:event, :date => "").should_not be_valid
  end

  it "is sent by a resource adapter" do
    expect(event.resource_id).to_not be_nil
    FactoryGirl.build(:event, :resource_id => "").should_not be_valid
  end

  it "has a valid resource id" do
    expect(event.resource_id).to be > 0
    expect(event.resource_id).should_not eq('')
  end

  it "must have at least one data entry" do
    expect(create(:event_with_details).detail.length).to be(1)
    expect(create(:event_with_details, details_count: 666).detail.length).to be(666)
  end

  it "has to belong to push or pull category" do
    expect(event.category).to include('push')
    expect(event.category).to_not be(/0-9/)
    event.category = 'pull'
    expect(event.category).to include('pull')
  end

end
