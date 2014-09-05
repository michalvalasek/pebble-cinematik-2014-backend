class EventsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def home
  end

  def next
    limit = params[:limit].to_i || 3
    @events = Event.where('date > ?',Time.now).order(:date).limit(limit)
  end
end