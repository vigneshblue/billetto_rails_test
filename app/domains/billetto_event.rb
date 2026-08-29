class BillettoEvent
  def initialize event_id, user_id=nil
    @event_id = event_id
    @user_id = user_id
  end

  def self.upvote event_id, user_id
    new(event_id, user_id).upvote
  end

  def self.downvote event_id, user_id
    new(event_id, user_id).downvote
  end

  def self.votes_count event_id
    new(event_id).votes_count
  end

  def upvote
    publish_event(EventUpvoted)
  end

  def downvote
    publish_event(EventDownvoted)
  end

  def votes_count
    votes = {}
    event_store = Rails.configuration.event_store
    events = event_store.read.stream("Event$#{@event_id}")

    events.each do |event|
      user_id = event.data[:user_id]
      case event
      when EventUpvoted
        votes[user_id] = :up
      when EventDownvoted
        votes[user_id] = :down
      end
    end

    upvotes = votes.values.count(:up)
    downvotes = votes.values.count(:down)
    { upvotes:, downvotes:}
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