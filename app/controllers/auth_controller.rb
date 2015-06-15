class AuthController < ApplicationController

  def new
  end

  def create
    if @user = User.find_by_username(auth_params[:username])
      if @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id
      redirect_to root_path, notice: ""
      else
        flash[:notice] = "Password is invalid"
        render :new
      end
    else
      flash[:notice] = "Username is invalid"
      render :new
    end
  end

  def destroy
    reset_session
    session.clear
    session[:user_id] = nil
    redirect_to root_path
  end

  private

  def auth_params
    params.permit(:username, :password, :session)
  end

end
