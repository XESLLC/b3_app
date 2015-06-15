class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :is_guest
  helper_method :current_user
  skip_before_action :verify_authenticity_token

  def is_guest
    if params[:signin] == "guest"
      session[:user_id] = User.find_by_username("JustPassingThrough").id
    end
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def is_signed_in_or_guest
    flash[notice] = "Please Sign In to Buy Stock" if !session[:user_id]
  end

end
