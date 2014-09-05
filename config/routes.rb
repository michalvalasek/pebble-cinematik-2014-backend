Rails.application.routes.draw do

  root 'events#home'

  get 'events/next(/:limit)' => 'events#next', as: :next_events
end