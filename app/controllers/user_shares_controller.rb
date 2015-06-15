class UserSharesController < ApplicationController

  before_action :current_user

  def new
    @user_share = UserShare.new
    @user_shares = current_user.user_shares
  end

  def create
    @user_share = UserShare.new(user_shares_params.merge(user_id: current_user.id))
    if @user_share.save
      intial_bid_points = params[:bid_points_share].to_i == 0 ? @user_share.team.points_per_share*10 : @user_share.number_of_shares*params[:bid_points_share].to_i
      Bid.create!(user_share_id: @user_share.id, shares: @user_share.number_of_shares, points: intial_bid_points.round(2))
      points = current_user.points_to_spend
      points_spent = @user_share.number_of_shares * @user_share.team.points_per_share
      current_user.update(points_to_spend: points-points_spent)
      flash[:notice] = "#{@user_share.number_of_shares} shares of #{Team.find(@user_share.team_id).name} successfully purchased!"
      redirect_to new_user_share_path
    else
      errors = @user_share.errors.full_messages.join("  ")
      flash[:notice] = "#{errors}"
      redirect_to new_user_share_path
    end
  end

  def destroy
    @user_share = UserShare.find(params[:id])
    if @user_share.delete
      points = current_user.points_to_spend
      points_return = @user_share.number_of_shares * @user_share.team.points_per_share
      current_user.update(points_to_spend: points + points_return)
      flash[:notice] = "#{@user_share.number_of_shares} shares of #{Team.find(@user_share.team_id).name} successfully removed!"
      redirect_to new_user_share_path
    end
  end


  private
  def user_shares_params
    params.require(:user_share).permit(:team_id, :number_of_shares)
  end

end
