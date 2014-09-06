partial = @render_thumbnails ? 'thumbnail' : 'event'
json.array! @events, partial: partial, as: :event