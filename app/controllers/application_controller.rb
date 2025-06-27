class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Add basic authentication to protect the entire app
  before_action :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      # You can customize these credentials or move them to environment variables
      username == ENV.fetch("BASIC_AUTH_USERNAME", "admin") &&
      password == ENV.fetch("BASIC_AUTH_PASSWORD", "password")
    end
  end
end
