require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    subject(:event) { Event.new(event_id: 121212, title: 'Sample Rock Fest') }

    it 'is valid with valid attributes' do
      expect(event).to be_valid
    end

    it 'is invalid without an event_id' do
      event.event_id = nil
      expect(event).not_to be_valid
      expect(event.errors[:event_id]).to include("can't be blank")
    end

    it 'is invalid without a title' do
      event.title = nil
      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("can't be blank")
    end

    it 'enforces a uniqueness constraint on event_id' do
      # Persist an initial entry to test collision boundaries
      Event.create!(event_id: 111111, title: 'First Fest')
      
      duplicate_event = Event.new(event_id: 111111, title: 'Second Fest')
      expect(duplicate_event).not_to be_valid
      expect(duplicate_event.errors[:event_id]).to include("has already been taken")
    end
  end

  describe 'scopes' do
    describe '.ordered' do
      let!(:later_event) { Event.create!(event_id: 131313, title: 'Late Event', start_date: 2.days.from_now) }
      let!(:earlier_event) { Event.create!(event_id: 111111, title: 'Early Event', start_date: 2.days.ago) }
      let!(:middle_event) { Event.create!(event_id: 121212, title: 'Middle Event', start_date: Time.current) }

      it 'returns events sorted chronologically by start_date ascending' do
        expect(Event.ordered).to eq([earlier_event, middle_event, later_event])
      end
    end
  end

  describe 'vote counters' do
    let(:event) { Event.new(event_id: 456456, title: 'Interactive Concert') }
    let(:mock_votes_payload) { { upvotes: 14, downvotes: 3 } }

    before do
      # Isolate the model spec by mocking the service class dependency entirely
      allow(BillettoEvent).to receive(:votes_count).with(456456).and_return(mock_votes_payload)
    end

    describe '#upvotes_count' do
      it 'extracts the upvotes integer field from the service matrix' do
        expect(event.upvotes_count).to eq(14)
      end
    end

    describe '#downvotes_count' do
      it 'extracts the downvotes integer field from the service matrix' do
        expect(event.downvotes_count).to eq(3)
      end
    end
  end
end