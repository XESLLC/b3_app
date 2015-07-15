class AskController < ApplicationController

  def update
    @ask = Ask.find(params[:id])
    @user_share = @ask.user_share
    same_as_other_ask = UserShare.find(@user_share.id).asks.where(points: ask_params[:points]).length > 0
    if @ask.points != ask_params[:points] && @ask.shares >= ask_params[:shares].to_i && same_as_other_ask
      @ask.update(shares: @ask.shares - ask_params[:shares].to_i)
      @ask_add_shares = UserShare.find(@user_share.id).asks.where(points: ask_params[:points])[0]
      @ask_add_shares.update(shares: @ask_add_shares[:shares] + ask_params[:shares].to_i)
      flash[:notice] = "You combined shares!"
      redirect_to edit_user_share_path(@ask.user_share)
    elsif  @ask.shares != ask_params[:shares].to_i && @ask.points != ask_params[:points] && @ask.shares > ask_params[:shares].to_i
      @ask.update(shares: @ask.shares - ask_params[:shares].to_i,)
      new_ask = Ask.new(ask_params.merge(user_share_id: @user_share.id))
      new_ask.save
      flash[:notice] = "You split shares!"
      redirect_to edit_user_share_path(@ask.user_share)
    elsif @ask.shares == ask_params[:shares].to_i &&  @ask.points != ask_params[:points]
      @ask.update(points: ask_params[:points])
      flash[:notice] = "You changed ask points!"
      redirect_to edit_user_share_path(@ask.user_share)
    elsif @ask.shares < ask_params[:shares].to_i
      flash[:notice] = "Error - Too Many Shares"
      redirect_to edit_user_share_path(@ask.user_share)
    end
  end

  def update_js
    @ask = Ask.find(ask_params[:team_id])
    @user_share = @ask.user_share
    same_as_other_ask = UserShare.find(@user_share.id).asks.where(points: ask_params[:points]).length > 0
    if @ask.points != ask_params[:points] && @ask.shares >= ask_params[:shares].to_i && same_as_other_ask
      @ask.update(shares: @ask.shares - ask_params[:shares].to_i)
      @ask_add_shares = UserShare.find(@user_share.id).asks.where(points: ask_params[:points])[0]
      @ask_add_shares.update(shares: @ask_add_shares[:shares] + ask_params[:shares].to_i)
      flash[:notice] = "You combined shares!"
    elsif  @ask.shares != ask_params[:shares].to_i && @ask.points != ask_params[:points] && @ask.shares > ask_params[:shares].to_i
      @ask.update(shares: @ask.shares - ask_params[:shares].to_i,)
      new_ask = Ask.new(user_share_id: @user_share.id, shares: ask_params[:shares], points: ask_params[:points])
      new_ask.save
      flash[:notice] = "You split shares!"
    elsif @ask.shares == ask_params[:shares].to_i &&  @ask.points != ask_params[:points]
      @ask.update(points: ask_params[:points])
      flash[:notice] = "You changed ask points!"
    elsif @ask.shares < ask_params[:shares].to_i
      flash[:notice] = "Error - Too Many Shares"
    end
    respond_to do |format|
      format.json { render json: {team: @user_share.team, ask: @ask}}
    end
  end

  private
  def ask_params
    params.require(:ask).permit(:shares, :points, :team_id)
  end

end
