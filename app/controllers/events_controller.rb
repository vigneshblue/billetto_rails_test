class EventsController < ApplicationController
  before_action :require_clerk_session!, except: [:index]
  before_action :set_event_and_user, only: [:upvote, :downvote]

  def index
    @pagy, @events = pagy(:offset, Event.all.ordered)
  end

  def upvote    
  end

  def downvote
  end

  private

    def set_event_and_user
      @event = Event.find(params[:id])
      @event_id = @event.event_id
      @user_id = @current_user.user_id
    end
end
