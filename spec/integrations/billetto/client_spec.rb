require 'rails_helper'

RSpec.describe Billetto::Client, type: :integration do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:test_connection) do
    Faraday.new(url: described_class::BASE_URL) do |builder|
      builder.headers['accept'] = 'application/json'
      builder.headers['Api-Keypair'] = 'test_keypair'
      builder.adapter :test, stubs
    end
  end

  before do
    allow(described_class).to receive(:connection).and_return(test_connection)
    allow(Rails.application.credentials).to receive(:billetto_api_keypair).and_return('test_keypair')
  end

  after do
    stubs.verify_stubbed_calls
  end

  describe '.list_public_events' do
    let(:endpoint) { '/api/v3/public/events' }
    let(:api_response_body_1) do
      {
        'data' => [{ 'id' => 121212, 'title' => 'Concert' }],
        'has_more' => true,
        'next' => 212121
      }.to_json
    end

    let(:api_response_body_2) do
      {
        'data' => [{ 'id' => 101010, 'title' => 'Concert' }],
        'has_more' => false,
        'next' => nil
      }.to_json
    end

    context 'when the database has no previous events' do
      before do
        allow(Event).to receive(:last).and_return(nil)
        stubs.get(endpoint) do |env|
          expect(env.params).to eq('limit' => '10')
          [200, { 'Content-Type' => 'application/json' }, api_response_body_1]
        end
      end

      it 'queries the API with the limit parameter and returns parsed payload' do
        data, has_more = described_class.list_public_events(10)
        expect(data).to eq([{ 'id' => 121212, 'title' => 'Concert' }])
        expect(has_more).to be_in([true, false])
        expect(data.first['next']).to be_nil.or be_present
      end
    end

    context 'when a previous event exists in the database' do
      let(:mock_event) { instance_double(Event, event_id: 292929) }

      before do
        allow(Event).to receive(:last).and_return(mock_event)
        stubs.get(endpoint) do |env|
          expect(env.params).to eq('limit' => '100', 'after' => '292929')
          [200, { 'Content-Type' => 'application/json' }, api_response_body_2]
        end
      end

      it 'appends the after parameter automatically to the API query' do
        data, has_more = described_class.list_public_events
        expect(data.first['id']).to eq(101010)
        expect(has_more).to be_in([true, false])
        expect(data.first['next']).to be_nil.or be_present
      end
    end

    context 'when the API endpoint returns an error status' do
      before do
        allow(Event).to receive(:last).and_return(nil)
        stubs.get(endpoint) { [500, {}, 'Internal Server Error'] }
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error to Rails and raises a runtime exception' do
        expect(Rails.logger).to receive(:error).with('Billetto API request failed: status=500')
        expect { described_class.list_public_events }.to raise_error(RuntimeError, 'Billetto API request failed: 500')
      end
    end
  end
end