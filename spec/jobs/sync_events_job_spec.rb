require 'rails_helper'

RSpec.describe SyncEventsJob, type: :job do
  describe '#perform' do
    let(:page_1_events) { [ { 'id' => 121212, 'title' => 'Opening Ceremony' } ] }
    let(:page_2_events) { [ { 'id' => 212121, 'title' => 'Main Concert' } ] }

    before do
      allow(Rails.logger).to receive(:info)
      allow(Billetto::Events).to receive(:create)
    end

    context 'when the API has multiple pages of data' do
      before do
        # Simulates 2 pages: first returns has_more: true, second returns has_more: false
        allow(Billetto::Client).to receive(:list_public_events).and_return(
          [ page_1_events, true ],
          [ page_2_events, false ]
        )
      end

      it 'recursively fetches and processes all event batches within the same job' do
        described_class.new.perform

        expect(Billetto::Events).to have_received(:create).with(page_1_events)
        expect(Billetto::Events).to have_received(:create).with(page_2_events)
      end

      it 'logs progress at the start and end of the sync run' do
        described_class.new.perform
        expect(Rails.logger).to have_received(:info).with('Starting Billetto events sync')
        expect(Rails.logger).to have_received(:info).with('Finished Billetto events sync')
      end
    end

    context 'when the API returns an empty event array' do
      before do
        allow(Billetto::Client).to receive(:list_public_events).and_return([ [], true ])
      end

      it 'safely hits the circuit breaker and stops execution immediately' do
        described_class.new.perform

        expect(Billetto::Events).not_to have_received(:create)
      end
    end
  end
end
