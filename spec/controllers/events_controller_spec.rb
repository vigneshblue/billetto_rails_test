require 'rails_helper'

RSpec.describe "Events Management", type: :request do
  let!(:mock_event) do
    Event.create!(
      event_id: 121212,
      title: 'Controller Test Concert',
      start_date: Time.current
    )
  end

  let(:mock_user) { instance_double('User', user_id: 'usr_444') }

  before do
    # Bypass authentication filter globally for this controller spec
    allow_any_instance_of(EventsController).to receive(:require_clerk_session!).and_return(true)
    
    # Inject current user hook configuration
    allow_any_instance_of(EventsController).to receive(:set_event_and_user) do |controller|
      controller.instance_variable_set(:@event, mock_event)
      controller.instance_variable_set(:@event_id, mock_event.event_id)
      controller.instance_variable_set(:@current_user, mock_user)
      controller.instance_variable_set(:@user_id, mock_user.user_id)
    end

    allow(BillettoEvent).to receive(:upvote)
    allow(BillettoEvent).to receive(:downvote)
  end

  describe 'GET /events' do
    before do
      pagy_double = double('Pagy', series_nav: '<!-- Mocked Pagy Navigation -->')
      allow_any_instance_of(EventsController).to receive(:pagy).and_return([pagy_double, [mock_event]])
    end

    it 'renders the index page successfully' do
      get events_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /events/:id/upvote' do
    it 'delegates downstream to the BillettoEvent class' do
      post upvote_event_path(mock_event), headers: { 'HTTP_REFERER' => '/previous_page' }

      expect(BillettoEvent).to have_received(:upvote).with(mock_event.event_id, mock_user.user_id)
    end

    it 'redirects back successfully with a flash notice' do
      post upvote_event_path(mock_event), headers: { 'HTTP_REFERER' => '/previous_page' }

      expect(response).to redirect_to('/previous_page')
      expect(flash[:notice]).to eq('Upvoted successfully!')
    end
  end

  describe 'POST /events/:id/downvote' do
    it 'delegates downstream to the BillettoEvent class' do
      post downvote_event_path(mock_event), headers: { 'HTTP_REFERER' => '/previous_page' }

      expect(BillettoEvent).to have_received(:downvote).with(mock_event.event_id, mock_user.user_id)
    end

    it 'redirects back successfully with a flash notice' do
      post downvote_event_path(mock_event), headers: { 'HTTP_REFERER' => '/previous_page' }

      expect(response).to redirect_to('/previous_page')
      expect(flash[:notice]).to eq('Downvoted successfully!')
    end
  end
end