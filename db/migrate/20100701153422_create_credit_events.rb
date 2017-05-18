class CreateCreditEvents < ActiveRecord::Migration
  def self.up
    create_table :credit_events do |t|
      t.integer :user_id
      t.string  :pegged_currency_amount_iso_currency_code #USD
      t.string  :premium_currency_amount #500
      t.string  :offer_id #nvdo9h70w2i5eum8a9ra4og2b
      t.string  :socialgold_transaction_id #8179529fe03c6d58ef04ef53ceb8a5fc
      t.string  :net_payout_amount #549
      t.string  :cc_token #t7evqmnzjyvos4y3776diqm8sltc4jf
      t.string  :billing_country_code #US
      t.boolean :simulated, :default => false, :null => false #true
      t.string  :pegged_currency_amount #611
      t.string  :offer_amount #500
      t.string  :socialgold_transaction_status #SUCCESS
      t.string  :amount #500
      t.string  :pegged_currency_label #USD
      t.string  :version #1
      t.string  :premium_currency_label #Buddy Beers Bucks
      t.string  :offer_amount_iso_currency_code #EUR
      t.string  :billing_zip #98121
      t.string  :user_balance #500
      t.string  :event_type #BOUGHT_CURRENCY
      t.string  :external_ref_id 
      t.string  :timestamp
      t.string  :signature
      t.string  :name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :credit_events
  end
end
