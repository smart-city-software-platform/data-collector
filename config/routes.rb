Rails.application.routes.draw do

  get 'pubsub/demo'

  resources :events, only: [:show, :index], defaults: {format: :json} do
  	resources :details,
  				defaults: {format: :json},
  				only: [:show, :index]
  end

  resources :resources_collector, only: [:create, :update]
  resources :events, only: [:create]
  resources :platform_resources, only: [:create, :update], path: 'resources'

  post 'sensor_values' => 'sensor_values#resources_data', path: 'resources/data', defaults: {format: :json}
  post 'sensor_value' => 'sensor_values#resource_data', path: 'resources/:uuid/data', defaults: {format: :json}
  post 'sensor_values_last' => 'sensor_values#resources_data_last', path: 'resources/data/last', defaults: {format: :json}
  post 'sensor_value_last' => 'sensor_values#resource_data_last', path: 'resources/:uuid/data/last', defaults: {format: :json}

end
