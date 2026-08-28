class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  include Clerk::Authenticatable
  include Pagy::Method
  before_action :set_current_user

  private

    def set_current_user
      return unless clerk.session
      @current_user = User.find_or_create_by!(clerk_user_id: clerk.user_id)
    end

    def require_clerk_session!
      redirect_to clerk.sign_in_url unless clerk.session
    end
end
