class BidController < ApplicationController


    def update
      @bid = Bid.find(params[:id])
      @user_share = @bid.user_share
      same_as_other_bid = UserShare.find(@user_share.id).bids.where(points: bid_params[:points]).length > 0
      if @bid.points != bid_params[:points] && @bid.shares >= bid_params[:shares].to_i && same_as_other_bid
        @bid.update(shares: @bid.shares - bid_params[:shares].to_i)
        @bid_add_shares = UserShare.find(@user_share.id).bids.where(points: bid_params[:points])[0]
        @bid_add_shares.update(shares: @bid_add_shares[:shares] + bid_params[:shares].to_i)
        flash[:notice] = "You combined shares!"
        redirect_to edit_user_share_path(@bid.user_share)
      elsif  @bid.shares != bid_params[:shares].to_i && @bid.points != bid_params[:points] && @bid.shares > bid_params[:shares].to_i
        @bid.update(shares: @bid.shares - bid_params[:shares].to_i,)
        new_bid = Bid.new(bid_params.merge(user_share_id: @user_share.id))
        new_bid.save
        flash[:notice] = "You split shares!"
        redirect_to edit_user_share_path(@bid.user_share)
      elsif @bid.shares == bid_params[:shares].to_i &&  @bid.points != bid_params[:points]
        @bid.update(points: bid_params[:points])
        flash[:notice] = "You changed bid points!"
        redirect_to edit_user_share_path(@bid.user_share)
      elsif @bid.shares < bid_params[:shares].to_i
        flash[:notice] = "Error - Too Many Shares"
        redirect_to edit_user_share_path(@bid.user_share)
      end
    end

    private
    def bid_params
      params.require(:bid).permit(:shares, :points)
    end

end
