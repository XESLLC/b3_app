class AuthController < ApplicationController

  def new
  end

  def create
    if @user = User.find_by_username(auth_params[:username])
      if @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id
      redirect_to root_path
      end
    else
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def auth_params
    params.permit(:username, :password)
  end

end
