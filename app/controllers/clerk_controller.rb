class ClerkController < ApplicationController
  before_action :redirect_if_signed_in, only: [ :sign_up, :sign_in ]

  def sign_up
  end

  def sign_in
  end

  def sign_out
  end

  private

    def redirect_if_signed_in
      redirect_to root_path if @current_user
    end
end
