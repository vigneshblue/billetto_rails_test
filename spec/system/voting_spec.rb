require 'rails_helper'

RSpec.describe "Voting", type: :system do
  let!(:event) do
    Event.create!(
      event_id: 121212,
      title: "System Test Concert",
      start_date: Time.current
    )
  end

  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "Unauthenticated voting" do
    it "redirects an unauthenticated user to sign in when clicking Upvote" do
      visit events_path

      click_on "Upvote"

      expect(page).to have_current_path(ENV["CLERK_SIGN_IN_URL"])
      expect(page).to have_css('.cl-signIn-root', wait: 10)
      expect(page).to have_content("Sign in to billetto_rails_test")
    end

    it "redirects an unauthenticated user to sign in when clicking Downvote" do
      visit events_path

      click_on "Downvote"

      expect(page).to have_current_path(ENV["CLERK_SIGN_IN_URL"])
      expect(page).to have_css('.cl-signIn-root', wait: 10)
      expect(page).to have_content("Sign in to billetto_rails_test")
    end
  end

  describe "Authenticated voting" do
    let(:clerk) { double("Clerk", session: double("Session"), user_id: "usr_444") }

    before do
      allow_any_instance_of(EventsController).to receive(:clerk).and_return(clerk)
    end

    it "allows an authenticated user to upvote an event" do
      visit events_path

      expect(page).to have_content("System Test Concert")

      click_on "Upvote"

      expect(page).to have_css(".upvote-count", text: 1)
    end

    it "allows an authenticated user to downvote an event" do
      visit events_path

      expect(page).to have_content("System Test Concert")

      click_on "Downvote"

      expect(page).to have_css(".downvote-count", text: 1)
    end

    it "does not increase the upvote count when the user upvotes again" do
      visit events_path

      expect(page).to have_content("System Test Concert")

      click_on "Upvote"

      expect(page).to have_css(".upvote-count", text: 1)

      click_on "Upvote"

      expect(page).to have_css(".upvote-count", text: 1)
    end

    it "does not increase the downvote count when the user downvotes again" do
      visit events_path

      expect(page).to have_content("System Test Concert")

      click_on "Downvote"

      expect(page).to have_css(".downvote-count", text: 1)

      click_on "Downvote"

      expect(page).to have_css(".downvote-count", text: 1)
    end
  end
end
