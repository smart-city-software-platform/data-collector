Rails.application.routes.draw do

  #get 'details/index'
  #get 'details/show'

  resources :events, only: [:show, :index], defaults: {format: :json} do
  	resources :details,
  				defaults: {format: :json},
  				only: [:show, :index]
  end

  resources :resources_collector, only: [:create, :update]

end