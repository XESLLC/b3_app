class UserSharesController < ApplicationController

  before_action :current_user

  def new
    @user_share = UserShare.new
    @user_shares = current_user.user_shares
  end

  def create
    @user_share = UserShare.where(user_id: current_user.id, team_id: user_shares_params[:team_id])[0]
    if @user_share.present?
      is_saved_or_update = @user_share.update!(number_of_shares: @user_share[:number_of_shares] + user_shares_params[:number_of_shares].to_i)
    else
      @user_share = UserShare.new(user_shares_params.merge(user_id: current_user.id))
      is_saved_or_update = @user_share.save
    end
    if is_saved_or_update
      params[:ask_points_share] == "" ? intial_ask_points = @user_share.team.points_per_share*10 : intial_ask_points = @user_share.number_of_shares*params[:ask_points_share].to_i
      Ask.create!(user_share_id: @user_share.id, shares: @user_share.number_of_shares, points: intial_ask_points.round(2))
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

  def edit
    @asks = UserShare.find(params[:id]).asks
    @bids = UserShare.find(params[:id]).bids
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

  def create_bid
    team = Team.find_by_name(params[:team_name])
    @user_share = current_user.user_shares.where(team_id: team.id).first
    if @user_share && @user_share != []
      @bid = Bid.create!(user_share_id: @user_share.id, shares: bid_params[:bid_shares], points: bid_params[:bid_points_share])
    else
      @user_share = UserShare.create!(user_id: current_user.id, team_id: team.id, number_of_shares: 0)
      @bid = Bid.create!(user_share_id: @user_share.id, shares: bid_params[:bid_shares], points: bid_params[:bid_points_share])
    end
    respond_to do |format|
    format.json { render json: {team: team, bid: @bid }}
    end

  end

  # def create_ask
  #   team = Team.find(params[:id])
  #   user_share = team.user_shares.where(user_id: current_user.id).first
  #   @ask = user_share.asks.where(points: points)
  #   @user_share = @ask.user_share
  #   same_as_other_ask = UserShare.find(@user_share.id).asks.where(points: ask_params[:points]).length > 0
  #   if @ask.points != ask_params[:points] && @ask.shares >= ask_params[:shares].to_i && same_as_other_ask
  #     @ask.update(shares: @ask.shares - ask_params[:shares].to_i)
  #     @ask_add_shares = UserShare.find(@user_share.id).asks.where(points: ask_params[:points])[0]
  #     @ask_add_shares.update(shares: @ask_add_shares[:shares] + ask_params[:shares].to_i)
  #     flash[:notice] = "You combined shares!"
  #     redirect_to edit_user_share_path(@ask.user_share)
  #   elsif  @ask.shares != ask_params[:shares].to_i && @ask.points != ask_params[:points] && @ask.shares > ask_params[:shares].to_i
  #     @ask.update(shares: @ask.shares - ask_params[:shares].to_i,)
  #     new_ask = Ask.new(ask_params.merge(user_share_id: @user_share.id))
  #     new_ask.save
  #     flash[:notice] = "You split shares!"
  #     redirect_to edit_user_share_path(@ask.user_share)
  #   elsif @ask.shares == ask_params[:shares].to_i &&  @ask.points != ask_params[:points]
  #     @ask.update(points: ask_params[:points])
  #     flash[:notice] = "You changed ask points!"
  #     redirect_to edit_user_share_path(@ask.user_share)
  #   elsif @ask.shares < bid_params[:shares].to_i
  #     flash[:notice] = "Error - Too Many Shares"
  #     redirect_to edit_user_share_path(@bid.user_share)
  #   end
  # end

  private
  def user_shares_params
    params.require(:user_share).permit(:team_id, :number_of_shares)
  end

  def bid_params
    params.permit(:team_name, :bid_shares, :bid_points_share)
  end

  def ask_params
    params.require(:ask).permit(:team_id, :team_name, :ask_shares, :ask_points_share)
  end

end
