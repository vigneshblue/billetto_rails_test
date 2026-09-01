require 'rails_helper'

RSpec.describe "Authentication", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "Visiting sign_in and sign_up pages" do
    it "successfully loads the sign_up page" do
      visit root_path
      click_on "Sign up"

      expect(page).to have_css('.cl-signUp-root', wait: 5)
      expect(page).to have_content("Create your account") 
    end

    it "successfully loads the sign_in page" do
      visit root_path
      click_on "Sign in"

      expect(page).to have_css('.cl-signIn-root', wait: 5)
      expect(page).to have_content("Sign in to billetto_rails_test") 
    end
  end

  describe "Logout" do
    it "successfully sign out on clicking sign out" do
      visit "/sign_in"

      expect(page).to have_content("Sign in to billetto_rails_test", wait: 5) 
      fill_in 'identifier', with: ENV["CLERK_TEST_USER"]
      click_on 'Continue'

      expect(page).to have_content("Enter your password")
      fill_in 'password', with: ENV["CLERK_TEST_PASSWORD"]
      click_on 'Continue'

      expect(page).to have_css('.cl-signIn-root', wait: 5)
      find('#user-button').click
      click_on 'Sign out'

      expect(page).to have_link("Sign in")
    end
  end
end