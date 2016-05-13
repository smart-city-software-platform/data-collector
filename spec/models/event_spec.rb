require 'rails_helper'

describe Event, :type => :model do
  
  let(:event) { create(:event) }

  it "has a valid factory" do
    expect(event).to be_valid
  end

  it "has a date of occurence" do
  	expect(event.date).should_not be_nil
  end

  it "is sent by a resource adapter" do
  	expect(event.resource_id).to_not be_nil
  	expect(event.resource_id).should_not eq('')  	
  end

  it "has a valid resource id" do
  	expect(event.resource_id).to be > 0
  end

  it "must have at least one data entry" do
  	expect(create(:event_with_details).detail.length).to be(1)
  end

  it "can be described as a JSON object"
end
