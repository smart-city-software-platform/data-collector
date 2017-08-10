# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  get 'pubsub/demo'

  mount Sidekiq::Web => '/sidekiq'

  scope 'resources', via: [:post], defaults: { format: :json } do
    match 'data', as: 'resources_data',
                  to: 'sensor_values#resources_data'
    match ':uuid/data', as: 'resource_data',
                        to: 'sensor_values#resource_data'
    match 'data/last', as: 'resources_data_last',
                       to: 'sensor_values#resources_data_last'
    match ':uuid/data/last', as: 'resource_data_last',
                             to: 'sensor_values#resource_data_last'
  end
end
