class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  include Clerk::Authenticatable
  include Pagy::Method

  private

    def require_clerk_session!
      redirect_to clerk.sign_in_url unless clerk.session
    end
end
