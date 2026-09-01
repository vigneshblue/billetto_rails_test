require 'rails_helper'

RSpec.describe Billetto::Events, type: :model do
  describe '.create' do
    let(:events_arr) do
      [
        {
          'id' => 232323,
          'title' => 'Rock Festival',
          'description' => 'Outdoor rock music event.',
          'startdate' => '2026-09-20T18:00:00Z',
          'image_link' => 'https://images.com',
          'url' => 'https://billetto.dk',
          'location' => { 'country' => 'Denmark' }
        }
      ]
    end

    before do
      allow(Rails.logger).to receive(:error)
    end

    context 'when the event does not exist in the database' do
      it 'creates a new Event record with all mapped fields' do
        expect { described_class.create(events_arr) }.to change(Event, :count).by(1)

        created_event = Event.find_by!(event_id: 232323)
        expect(created_event.title).to eq('Rock Festival')
        expect(created_event.description).to eq('Outdoor rock music event.')
        expect(created_event.country).to eq('Denmark')
      end
    end
    context 'when the event already exists in the database' do
      let!(:existing_event) do
        Event.create!(
          event_id: 232323,
          title: 'Old Title',
          description: 'Old Description',
          start_date: '2026-01-01',
          image_url: 'https://images.com',
          event_url: 'https://billetto.dk',
          country: 'Sweden'
        )
      end

      it 'does not create a duplicate Event record' do
        expect { described_class.create(events_arr) }.not_to change(Event, :count)
      end

      it 'updates the attributes of the existing record' do
        described_class.create(events_arr)

        existing_event.reload
        expect(existing_event.title).to eq('Rock Festival')
        expect(existing_event.country).to eq('Denmark')
      end
    end

    context 'when the location structure is missing from the payload' do
      let(:missing_location_arr) do
        [
          {
            'id' => 323232,
            'title' => 'Minimal Event',
            'location' => nil
          }
        ]
      end

      it 'uses .dig to safely assign nil to the country without raising an exception' do
        expect { described_class.create(missing_location_arr) }.not_to raise_error

        created_event = Event.find_by(event_id: 323232)
        expect(created_event.country).to be_nil
      end
    end

    context 'when saving an event fails validation' do
      before do
        # Simulating a validation failure on save by forcing an error onto the instance
        allow_any_instance_of(Event).to receive(:save).and_return(false)

        # Stub errors to look like standard ActiveRecord model errors
        errors_stub = double('Errors', full_messages: [ 'Title cannot be blank' ])
        allow_any_instance_of(Event).to receive(:errors).and_return(errors_stub)
      end

      it 'logs a structured validation error payload and continues execution' do
        described_class.create(events_arr)

        expect(Rails.logger).to have_received(:error).with(
          'Failed to sync Billetto event 232323: Title cannot be blank'
        )
      end
    end
  end
end
