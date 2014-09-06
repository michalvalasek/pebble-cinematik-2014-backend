Rails.application.routes.draw do

  root 'events#home'

  get 'events/upcoming(/:limit)' => 'events#upcoming', as: :upcoming_events
  get 'events/:id' => 'events#show', as: :event
  get 'events/:id/next' => 'events#next', as: :next_event
end
