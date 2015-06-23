class AskController < ApplicationController

  def update
    @ask = Ask.find(params[:id])
    @user_share = @ask.user_share
    same_as_other_ask = UserShare.find(@user_share.id).asks.where(points: ask_params[:points]).length > 0
    if @ask.points != ask_params[:points] && @ask.shares >= ask_params[:shares].to_i && same_as_other_ask
      @ask.update(shares: @ask.shares - ask_params[:shares].to_i)
      if @ask[:shares] == 0
        @ask.destroy
      end
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
    end
  end




  #   if @ask.shares == ask_params[:ask][:shares].to_i && @ask.price != ask_params[:points]
  #     @ask.update(points: ask_params[:points])
  #     flash[:notice] = "Ask was updated!"
  #     end
  #   elsif  @ask.shares != ask_params[:ask][:shares].to_i && @ask.price != ask_params[:points]
  #     @ask.update(shares: @ask.shares - params[:ask][:shares].to_i)
  #     same_as_other_ask = Ask.all.where(points: ask_params[:points])[0]
  #       if same_as_other_ask == [] || same_as_other_ask ==   nil
  #         new_ask = Ask.new(ask_params.merge(user_share_id: @user_share.id))
  #         new_ask.save
  #         flash[:notice] = "New ask created, old one updated!"
  #       else
  #         same_as_other_ask.update(shares: same_as_other_ask.shares + ask_params[:points])
  #       end
  #   elsif @ask.shares > ask_params[:ask][:shares].to_i && @ask.price == ask_params[:points] && @user_share.asks.length > 1
  #     if @user_share.shares > @ask.shares+
  #     @ask.update(shares: ask_params[:shares].to_i)
  #
  #     @user_share.asks.
  #     flash[:notice] = "You selected too many shares!"
  #   end
  #     redirect_to edit_user_share_path(@ask.user_share)
  # end
  #
  #
  private
  def ask_params
    params.require(:ask).permit(:shares, :points)
  end

end
