require 'rails_helper'

RSpec.describe PlatformResourcesController, type: :controller do

  subject {response}

  # Create objects from factories
  let(:empty_capability) {
    FactoryGirl.build(:empty_capability)
  }

  let(:missing_args_params) {
    FactoryGirl.attributes_for(:missing_args)
  }

  let(:typo_params) {
    FactoryGirl.attributes_for(:typo)
  }

  let(:essential_args_params) {
    FactoryGirl.attributes_for(:essential_args)
  }

  let (:empty_capability_params) {
    FactoryGirl.attributes_for(:empty_capability)
  }

  let (:with_capability_params) {
    FactoryGirl.attributes_for(:with_capability)
  }

  it 'Has a valid factory' do
    expect(empty_capability).to be_valid
  end

  context 'Verify create method by POST using data with no capabilities' do

    it 'Verify request made successfully' do
      post :create, params: {data: essential_args_params}
      is_expected.to have_http_status(201)
    end

    it 'Verify if request was stored successfully' do
      expect{post :create, params: {data: essential_args_params}}
            .to change(PlatformResource, :count).by(1)
    end

    it 'Typo in parameter to post results in a server error' do
      post :create, params: {data: typo_params}
      is_expected.to have_http_status(500)
    end

    it 'Wrong number of arguments results in a server error' do
      post :create, params: {data: missing_args_params}
      is_expected.to have_http_status(500)
    end

  end

  context 'Verify create method by POST using data with capabilities' do
    it 'POST new platform resource with empty capabilities' do
      post :create, params: {data: empty_capability_params}
      is_expected.to have_http_status(201)
    end

    it 'Verify if POST correctly stored data with empty capabilities' do
      expect{post :create, params: {data: empty_capability_params}}
            .to change(PlatformResource, :count).by(1)
      expect(Capability.count)
            .to eq(empty_capability_params[:capabilities].size)
    end

    it 'POST new platform resource with one capability' do
      params = FactoryGirl.attributes_for(:with_capability,
                                          capabilities: ["weight"])

      post :create, params: {data: params}
      is_expected.to have_http_status(201)
    end

    it 'Verify if POST correctly stored data with one capability' do
      params = FactoryGirl.attributes_for(:with_capability,
                                          capabilities: ["weight"])

      expect{post :create, params: {data: params}}
            .to change(PlatformResource, :count).by(1)
      expect(Capability.count).to eq(params[:capabilities].size)
    end

    it 'POST new platform resource with multiple capabilities' do
      post :create, params: {data: with_capability_params}
      is_expected.to have_http_status(201)
    end

    it 'Verify if POST correctly stored data with multiple capabilities' do
      expect{post :create, params: {data: with_capability_params}}
            .to change(PlatformResource, :count).by(1)
      expect(Capability.count)
            .to eq(with_capability_params[:capabilities].size)
    end

    it 'Accepts POST data with a mix of already created capabilities and new one' do
      first_cap = ["a", "b", "c"]
      second_cap = ["a", "b", "x"]

      first_params = FactoryGirl.attributes_for(:with_capability,
                                                capabilities: first_cap)
      second_params = FactoryGirl.attributes_for(:with_capability,
                                                 capabilities: second_cap)

      post :create, params: {data: first_params}
      is_expected.to have_http_status(201)
      post :create, params: {data: second_params}
      is_expected.to have_http_status(201)

      expect(Capability.count).to eq((first_cap + second_cap).uniq.size)
    end

    it 'Accepts POST data with all capabilities already created' do
      first_cap = ["a", "b"]
      second_cap = ["a", "b"]

      first_params = FactoryGirl.attributes_for(:with_capability,
                                                capabilities: first_cap)
      second_params = FactoryGirl.attributes_for(:with_capability,
                                                 capabilities: second_cap)

      post :create, params: {data: first_params}
      is_expected.to have_http_status(201)
      post :create, params: {data: second_params}
      is_expected.to have_http_status(201)

      # Must match with size of both arrays
      expect(Capability.count).to eq(first_cap.size)
      expect(Capability.count).to eq(second_cap.size)
    end

    it 'Verify if capability was stored correctly'
    it 'Verify relation between capability and platform resource'
  end

end
