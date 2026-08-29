class EventsController < ApplicationController
  before_action :require_clerk_session!, except: [:index]
  before_action :set_event_and_user, only: [:upvote, :downvote]

  def index
    @pagy, @events = pagy(:offset, Event.all.ordered)
  end

  def upvote
    vote_event = EventUpvoted.new(
      data:{ event_id: @event_id, user_id: @user_id }
    )

    Rails.configuration.event_store.publish(vote_event, stream_name: "Event$#{@event_id}")

    redirect_back fallback_location: root_path, notice: "Upvoted successfully!"    
  end

  def downvote
    vote_event = EventDownvoted.new(
      data:{ event_id: @event_id, user_id: @user_id }
    )
    
    Rails.configuration.event_store.publish(vote_event, stream_name: "Event$#{@event_id}")

    redirect_back fallback_location: root_path, notice: "Downvoted successfully!"
  end

  private

    def set_event_and_user
      @event = Event.find(params[:id])
      @event_id = @event.event_id
      @user_id = @current_user.user_id
    end
end
