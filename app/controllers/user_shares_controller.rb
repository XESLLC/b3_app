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
    @user_share = current_user.user_shares.where(team_id: team.id).first if current_user.user_shares.where(team_id: team.id)
    if @user_share && @user_share != []
      @bid = Bid.create!(user_share_id: @user_share.id, shares: bid_params[:bid_shares], points: bid_params[:bid_points_share])
    else
      @user_share = UserShare.create!(user_id: current_user.id, team_id: team.id, number_of_shares: 0)
      @bid = Bid.create!(user_share_id: @user_share.id, shares: bid_params[:bid_shares], points: bid_params[:bid_points_share])
    end

    @asks = Team.find(team[:id]).asks.order(points: :asc)
    @asks.each do |ask|
      if @bid.points >= ask.points

        if @bid.shares > ask.shares
          reduce_bid_remove_ask = @bid.shares - ask.shares
          @trade = Trade.create!(bid_id: @bid.id, ask_id: ask.id, points: ask.points*ask.shares)
          current_user.update!(points_to_spend: current_user.points_to_spend - @trade.points, points_spent: current_user.points_spent + @trade.points)
          ask.user_share.update!(number_of_shares: ask.user_share.number_of_shares - ask.shares)
          @bid.update!(shares: reduce_bid_remove_ask)
          ask.destroy
        elsif @bid.shares < ask.shares
          reduce_ask_remove_bid = ask.shares - @bid.shares
          @trade = Trade.create!(bid_id: @bid.id, ask_id: ask.id, points: ask.points*@bid.shares)
          current_user.update!(points_to_spend: current_user.points_to_spend - @trade.points, points_spent: current_user.points_spent + @trade.points)
          @user_share.update!(number_of_shares: @user_share.number_of_shares + @bid.shares)
          ask.user_share.update!(number_of_shares: ask.user_share.number_of_shares - @bid.shares)
          ask.update!(shares: reduce_ask_remove_bid)
          @bid.destroy
        elsif @bid.shares = ask.shares
          @trade = Trade.create(bid_id: @bid.id, ask_id: ask.id, points: ask.points*ask.shares)
          current_user.update!(points_to_spend: current_user.points_to_spend - @trade.points, points_spent: current_user.points_spent + @trade.points)
          ask.user_share.user.update!(points_to_spend: current_user.points_to_spend + @trade.points, points_spent: current_user.points_spent - @trade.points)
          @user_share.update!(number_of_shares: @user_share.number_of_shares + ask.shares)
          ask.user_share.update!(number_of_shares: ask.user_share.number_of_shares - ask.shares)
          @bid.destroy
          ask.destroy
        end

      end
    end

    if @bid
      respond_to do |format|
        format.json { render json: {team: team, bid: @bid, trade: @trade} }
      end
    end

  end

  def create_ask
    team = Team.find_by_name(params[:team_name])
    user_share = current_user.user_shares.where(team_id: team.id) if current_user.user_shares.where(team_id: team.id)

    if user_share && user_share != []
      @ask = Ask.create!(user_share_id: user_share.first.id, shares: ask_params[:ask_shares], points: ask_params[:ask_points_share])
    end

    @bids = Team.find(team[:id]).bids.order(points: :asc)
    @bids.each do |bid|

      if bid.points >= bid.points
        if bid.shares > @ask.shares
          reduce_bid_remove_ask = bid.shares - @ask.shares
          @trade = Trade.create!(bid_id: bid.id, ask_id: @ask.id, points: @ask.points*@ask.shares)
          bid.update!(shares: reduce_bid_remove_ask)
          @ask.destroy
        elsif bid.shares < @ask.shares
          reduce_bid_remove_ask = @ask.shares - bid.shares
          @trade = Trade.create!(bid_id: bid.id, ask_id: @ask.id, points: @ask.points*bid.shares)
          @ask.update!(shares: reduce_bid_remove_ask )
          bid.destroy
        elsif bid.shares = @ask.shares
          @trade = Trade.create(bid_id: bid.id, ask_id: @ask.id, points: @ask.points*@ask.shares)
          bid.destroy
          @ask.destroy
        end
      end
    end

    if @ask
      respond_to do |format|
        format.json { render json: {team: team, ask: @ask }}
      end
    end
  end

  private
  def user_shares_params
    params.require(:user_share).permit(:team_id, :number_of_shares)
  end

  def bid_params
    params.permit(:team_name, :bid_shares, :bid_points_share)
  end

  def ask_params
    params.permit(:team_name, :ask_shares, :ask_points_share)
  end

end
