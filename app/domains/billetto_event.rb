class BillettoEvent
  def initialize event_id, user_id
    @event_id = event_id
    @user_id = user_id
  end

  def self.upvote event_id, user_id
    new(event_id, user_id).upvote
  end

  def self.downvote event_id, user_id
    new(event_id, user_id).downvote
  end

  def upvote
    publish_event(EventUpvoted)
  end

  def downvote
    publish_event(EventDownvoted)
  end

  private

    def publish_event(event_class)
      vote_event = event_class.new(
        data: {
          event_id: @event_id,
          user_id: @user_id
        }
      )

      Rails.configuration.event_store.publish(
        vote_event,
        stream_name: "Event$#{@event_id}"
      )
    end
end