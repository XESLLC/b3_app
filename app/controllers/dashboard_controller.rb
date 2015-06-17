class DashboardController < ApplicationController

before_action :is_signed_in_or_guest

  def index
    is_guest
    @user = User.find(current_user.id) if current_user
    @teams = Team.all
    @bid_ask = {}
    @teams.each do |team|
      @bid_ask[team.id] = []
      @bid_ask[team.id] << {seed: team.seed}
      @bid_ask[team.id] << {name: team.name}
      bid_points = 0.00 if team.bids.last.nil?
      ask_points = 0.00 if team.asks.last.nil?
      @bid_ask[team.id] << {bid_points: bid_points || team.bids.reorder('points').last.points }
      @bid_ask[team.id] << {ask_points: ask_points || team.asks.reorder('points').last.points }
      user_team_shares = current_user.user_shares.where(team_id: team.id)
      @bid_ask[team.id] << {user_bids: [0]}
      @bid_ask[team.id] << {user_asks: [0]}
      user_team_shares.each do |user_team_share|
        @bid_ask[team.id][4][:user_bids] << 0
        @bid_ask[team.id][5][:user_asks] << 0
      end
    end

    @team_points_hash = {}
    @teams.each do |team|
      ask_points = []
      team.asks.each do |ask|
        ask_points << ask.trade.points if ask.trade
      end
      bid_points = []
      trade_points = [0]
      team.bids.each do |bid|
        bid_points << bid.points
        trade_points << bid.trade.points if bid.trade
      end
      if ask_points == [] || bid_points == []
        team_points = 0.0
      else
        team_points = ((ask_points.sort.first - bid_points.sort.last)/2) + bid_points.sort.last
      end
      @team_points_hash[:"#{team.name}"] = [team_points, team_points > trade_points.last ]
    end

    if current_user
      @user_share = UserShare.new
      @user_trades = []
      @user_shares = current_user.user_shares if current_user.user_shares
      current_user.bids.each do |bid|
        @user_trades << bid.trade if bid.trade
      end
      @total_points = current_user.points_to_spend + current_user.points_spent if current_user.points_to_spend.present? && current_user.points_spent
      @current_points = current_user.points_to_spend if current_user.points_to_spend
    else
      @user_trades = []
      @user_shares = []
      @total_points = 0
      @current_points = 0
    end

  end

  def pick_teams
    @user = User.find(current_user.id)
    if @user.update(last_session: params[:last_session])
      redirect_to root_path
    else
      respond_to do |format|
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def reload_pick_teams
    @user = User.find(current_user.id) if current_user
    if @user
      respond_to do |format|
        format.json { render json: @user.last_session }
      end
    else
      redirect_to root_path
    end
  end

end
