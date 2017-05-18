class RefreshUsersCredits < ActiveRecord::Migration
  def self.up
    @users = User.active
    @client = CurrencyClient.get_client
    @users.each do |user|
      @credits = @client.get_balance_for_display(user.id)
      user.update_attribute(:credits, @credits.to_i)
    end
  end

  def self.down
  end
end
