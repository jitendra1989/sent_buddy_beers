class AddPayoutModelsToBars < ActiveRecord::Migration
  def self.up
    Bar.all.each do |bar|
      bar.create_standard_payout_model!
    end
  end

  def self.down
  end
end
