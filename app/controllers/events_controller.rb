class EventsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def home
  end

  def upcoming
    limit = params[:limit] ? params[:limit].to_i : 3

    @events = Event.where('date > ?',Time.now).order(:date).limit(limit)
    if params[:place] && place = self.get_real_place_name(params[:place])
      @events = @events.where(place:place)
    end

    @render_thumbnails = ! params[:thumbnails].blank?
  end

  def show
    @event = Event.find(params[:id])
  end

  def next
    current_event = Event.find(params[:id])
    @event = Event.where('id > ?',current_event.id).order(:date).limit(1).first
  end

  def by_place
    place = get_real_place_name(params[:place])
    limit = params[:limit] ? params[:limit].to_i : 10
    @events = Event.where(place: place).order(:date).limit(limit)
  end

  protected

  def get_real_place_name(parametrized_name)
    places = {
      'fontana' => 'Fontána',
      'dom-umenia' => 'Dom umenia',
      'ziwell' => 'ŽiWell',
      'kino-klub' => 'Kino Klub',
      'amfiteater' => 'Amfiteáter'
    }
    place = places[parametrized_name]
  end
end
