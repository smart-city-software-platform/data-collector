require 'rails_helper'

RSpec.describe PlatformResourcesController, type: :controller do

  subject {response}
  let(:resource_without_capability) {FactoryGirl.build :platform_resource,
                                                       :default_no_capability}
  let(:default_resource_params) {FactoryGirl.attributes_for(:platform_resource,
                                                    :default_no_capability)}
  let(:default_resource_params_2) {FactoryGirl.attributes_for(
                                      :platform_resource,
                                      :default_2_no_capability)}
  let(:default_missing_params) {FactoryGirl.attributes_for(:platform_resource,
                                                    :missing_argument)}
  let(:typo) {FactoryGirl.attributes_for(:platform_resource,
                                          :typo_no_capability)}
  let(:resources_with_capability_params) {FactoryGirl.attributes_for(
                                          :platform_resource,
                                          :resource_with_capability)}

  let(:resource_empty_capability_params) {FactoryGirl.attributes_for(
                                         :platform_resource,
                                         :resource_empty_capability)}

  it 'Has a valid factory' do
    expect(resource_without_capability).to be_valid
  end

  context 'Verify create method without capabilities' do

    it 'Verify request end successfully' do
      post :create, params: {data: default_resource_params}
      is_expected.to have_http_status(201)
    end

    it 'Verify if request was stored and end successfully' do
      expect{post :create, params: {data: default_resource_params_2}}
                                .to change(PlatformResource, :count).by(1)
    end

    it 'Typo in parameter to post' do
      post :create, params: {data: typo}
      is_expected.to have_http_status(500)
    end

    it 'Wrong number of arguments' do
      post :create, params: {data: default_missing_params}
      is_expected.to have_http_status(500)
    end

  end

  context 'Verify create method with capabilities' do
    it 'Post new platform resource with empty capabilities' do
      post :create, params: {data: resource_empty_capability_params}
      is_expected.to have_http_status(201)
    end

    it 'Post new platform resource with one capabilities'

    it 'Post new platform resource with multiple capabilities' do
      post :create, params: {data: resources_with_capability_params}
      is_expected.to have_http_status(201)
    end

    it 'Verify if post correctly stored data with capabilities' do
      expect{post :create, params: {data: resources_with_capability_params}}
                                  .to change(PlatformResource, :count).by(1)
      expect(Capability.count)
                  .to eq(resources_with_capability_params[:capabilities].size)
    end

    it 'Post new platform resource with a mix of already created capabilities and new one'
    it 'Post new platform resource with all capabilities already created'
    it 'Verify if capability was stored correctly'
    it 'Verify relation between capability and platform resource'
  end

end
