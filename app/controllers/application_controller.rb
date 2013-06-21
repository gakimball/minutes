class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def current_user
    @current_user ||= User.find_by(token: params[:token])
  end
end
