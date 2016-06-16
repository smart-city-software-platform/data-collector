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

end
