class ApplicationController < ActionController::API
  include ActionController::Serialization
  include Pundit

  rescue_from Pundit::NotAuthorizedError,         with: :forbidden
  rescue_from ActiveRecord::RecordNotFound,       with: :not_found
  rescue_from ActionController::ParameterMissing, with: :unprocessable_entity

  before_action :add_cors_headers
  before_action :authenticate

  after_action :verify_authorized,  except: [:options, :index]

  skip_before_action :authenticate, only: [:options]

  serialization_scope :current_user

  # Handles all OPTIONS requests
  def options
    head 204
  end

  private

  # Adds CORS headers to the response
  def add_cors_headers
    headers['Access-Control-Max-Age'] = '1728000'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE'
    headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type'
  end

  # Renders a 401 error
  def unauthorized
    headers['WWW-Authenticate'] = 'Bearer realm="API"'
    head :unauthorized
  end

  # Renders a 403 error
  def forbidden
    head :forbidden
  end

  # Renders a 404 error
  def not_found
    head :not_found
  end

  # Renders a 422 error
  def unprocessable_entity
    head :unprocessable_entity
  end

  # Ensures that the request comes from an authenticated user
  def authenticate
    unauthorized if current_user.nil?
  end

  # Returns the current user or nil if this is an anonymous request
  def current_user
    @current_user ||= User.find_by_access_token(access_token)
  end

  # Returns the provided access token
  def access_token
    request.headers['Authorization'].to_s.split.last
  end
end
