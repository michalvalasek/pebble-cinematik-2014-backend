Rails.application.routes.draw do

  root 'events#home'

  get 'events/upcoming(/:limit(/:thumbnails(/:place)))' => 'events#upcoming', as: :upcoming_events
  get 'events/place/:place(/:limit)' => 'events#by_place', as: :events_by_place
  get 'events/:id' => 'events#show', as: :event
  get 'events/:id/next' => 'events#next', as: :next_event
end
