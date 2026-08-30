require 'rails_helper'

RSpec.describe BillettoEvent, type: :model do
  let(:event_id) { 123123 }
  let(:user_id) { 'usr_789' }
  let(:stream_name) { "Event$#{event_id}" }
  let(:event_store) { Rails.configuration.event_store }

  describe '.upvote' do
    it 'publishes an EventUpvoted event to the correct stream' do
      described_class.upvote(event_id, user_id)

      # Read back from the stream to verify execution
      published_events = event_store.read.stream(stream_name).to_a
      
      expect(published_events.count).to eq(1)
      expect(published_events.first).to be_an_instance_of(EventUpvoted)
      expect(published_events.first.data).to eq(event_id: event_id, user_id: user_id)
    end
  end

  describe '.downvote' do
    it 'publishes an EventDownvoted event to the correct stream' do
      described_class.downvote(event_id, user_id)

      published_events = event_store.read.stream(stream_name).to_a
      
      expect(published_events.count).to eq(1)
      expect(published_events.first).to be_an_instance_of(EventDownvoted)
      expect(published_events.first.data).to eq(event_id: event_id, user_id: user_id)
    end
  end

  describe '.votes_count' do
    context 'when no events are present in the stream' do
      it 'returns zeroed counts' do
        expect(described_class.votes_count(event_id)).to eq(upvotes: 0, downvotes: 0)
      end
    end

    context 'when multiple distinct users vote' do
      before do
        event_store.publish(EventUpvoted.new(data: { event_id: event_id, user_id: 'user_1' }), stream_name: stream_name)
        event_store.publish(EventUpvoted.new(data: { event_id: event_id, user_id: 'user_2' }), stream_name: stream_name)
        event_store.publish(EventDownvoted.new(data: { event_id: event_id, user_id: 'user_3' }), stream_name: stream_name)
      end

      it 'correctly aggregates the totals' do
        expect(described_class.votes_count(event_id)).to eq(upvotes: 2, downvotes: 1)
      end
    end

    context 'when a single user alters their vote status sequentially' do
      before do
        # User first upvotes, then changes mind to downvote
        event_store.publish(EventUpvoted.new(data: { event_id: event_id, user_id: 'user_1' }), stream_name: stream_name)
        event_store.publish(EventDownvoted.new(data: { event_id: event_id, user_id: 'user_1' }), stream_name: stream_name)
      end

      it 'deduplicates state and registers only the latest interaction type' do
        expect(described_class.votes_count(event_id)).to eq(upvotes: 0, downvotes: 1)
      end
    end
  end
end