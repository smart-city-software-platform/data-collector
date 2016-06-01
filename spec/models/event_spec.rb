require 'rails_helper'

describe Event, :type => :model do

  let(:event) { create(:event) }

  it "has a valid factory" do
    expect(event).to be_valid
  end

  it "has a date of occurence" do
    expect(event.date).not_to be_nil
    expect(event.date).not_to eq('')
    expect(FactoryGirl.build(:event, :date => "")).not_to be_valid
    expect(FactoryGirl.build(:event, :date => nil)).not_to be_valid
  end

  it "is sent by a resource adapter" do
    expect(event.resource_uuid).to_not be_nil
    expect(FactoryGirl.build(:event, :resource_uuid => "")).not_to be_valid
    expect(FactoryGirl.build(:event, :resource_uuid => nil)).not_to be_valid
  end

  it "has a valid resource id" do
    expect(event.resource_uuid).not_to eq('')

    uuid_pattern = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
    expect(uuid_pattern.match(event.resource_uuid)).not_to be_nil
  end

  it "must have at least one data entry" do
    expect(create(:event_with_details).detail.length).to be(1)
    expect(create(:event_with_details, details_count: 666).detail.length).to be(666)
  end

end
