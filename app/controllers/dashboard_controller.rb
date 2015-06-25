class DashboardController < ApplicationController

before_action :is_signed_in_or_guest

  def index
    is_guest
    @user = User.find(current_user.id) if current_user
    @teams = Team.all.order(:name)
    @user_teams = []
    @user.user_shares.each {|share| @user_teams << @teams.find(share.team_id)} if current_user
    @user_teams.sort!{|a,b| a.name <=> b.name}
    @bid_ask = {}
    @teams.each do |team|
      @bid_ask[team.id] = {}
      @bid_ask[team.id][:seed] = team.seed
      @bid_ask[team.id][:name] = team.name
      bid_points = 0.00 if team.bids.last.nil?
      ask_points = 0.00 if team.asks.last.nil?
      @bid_ask[team.id][:bid_points] = bid_points || team.bids.reorder('points').last.points
      @bid_ask[team.id][:ask_points] = ask_points || team.asks.reorder('points').first.points
      current_user.present? ? user_team_shares = current_user.user_shares.where(team_id: team.id) : user_team_shares = []
      @bid_ask[team.id][:user_bids] = []
      @bid_ask[team.id][:user_asks] = []
      user_bids = []
      user_asks = []
        user_team_shares.each do |user_team_share|
          user_team_share.bids.each {|bid| user_bids = bid.points}
          @bid_ask[team.id][:user_bids] << user_bids if user_bids != []
          user_team_share.asks.each {|ask| user_asks = ask.points}
          @bid_ask[team.id][:user_asks] << user_asks if user_asks != []
        end
    end

    @team_points_hash = {}
    @teams.reverse.each do |team|
      bid_points = []
      trade_points = []
      team.bids.each do |bid|
        bid_points << bid.points
        trade_points << bid.trade.points if bid.trade
      end
      if trade_points != []
        team_points = bid_points.concat(trade_points).sort.sort.last
      elsif trade_points = [] && bid_points != []
        team_points = bid_points.sort.last
      else
        team_points = 0
      end
      @team_points_hash[:"#{team.name}"] = team_points
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
      respond_to do |format|
        format.json { render json: @user.last_session}
      end
    else
      respond_to do |format|
        format.json { render json: @user.errors, status: :unprocessable_entity}
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
      respond_to do |format|
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

end
