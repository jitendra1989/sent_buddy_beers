class Affiliate::BaseController < ApplicationController
  before_filter :require_affiliate, :unless => :bro_signed_in?
  before_filter :require_bro, :unless => :affiliate_signed_in?
  before_filter :get_affiliate_bars

  layout 'affiliate'

  protected

  def get_affiliate_bars
    @bars = current_user.bars
  end
end
