class EventsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def home
  end

  def upcoming
    limit = params[:limit].to_i || 3
    @events = Event.where('date > ?',Time.now).order(:date).limit(limit)
  end

  def show
    @event = Event.find(params[:id])
  end

  def next
    current_event = Event.find(params[:id])
    @event = Event.where('id > ?',current_event.id).order(:date).limit(1).first
  end
end