Rails.application.routes.draw do

  get 'pubsub/demo'

  resources :events, only: [:show, :index], defaults: {format: :json} do
  	resources :details,
  				defaults: {format: :json},
  				only: [:show, :index]
  end

  resources :events, only: [:create]
  resources :platform_resources,
            only: [:create, :update],
            param: :uuid, path: 'resources'

  scope 'resources', via: [:post], defaults: {format: :json} do
  	match 'data', :as => 'resources_data', :to => 'sensor_values#resources_data'
  	match ':uuid/data', :as => 'resource_data', :to => 'sensor_values#resource_data'
    match 'data/last', :as => 'resources_data_last', :to => 'sensor_values#resources_data_last'
    match ':uuid/data/last', :as => 'resource_data_last', :to => 'sensor_values#resource_data_last'
  end

end
