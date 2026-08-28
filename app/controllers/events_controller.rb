class EventsController < ApplicationController
  def index
    @pagy, @events = pagy(:offset, Event.all.ordered)
  end
end
