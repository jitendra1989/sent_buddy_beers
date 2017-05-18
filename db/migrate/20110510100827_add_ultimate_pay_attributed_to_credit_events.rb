class AddUltimatePayAttributedToCreditEvents < ActiveRecord::Migration
  def self.up
    add_column :credit_events, :token, :string # B4G7oLcLInsSo4E18XdPlmPCe9TVg9noOPWEH3yoeND
    add_column :credit_events, :no_lib, :boolean, :default => true, :null => false #1
    add_column :credit_events, :provider, :string, :default => "Social Gold", :null => false #this should set all previous Credit events to Social Gold
    add_column :credit_events, :site_id, :integer
    add_column :credit_events, :commtype, :string
    add_column :credit_events, :currency, :string
    add_column :credit_events, :detail, :string
    add_column :credit_events, :gwtid, :string
    add_column :credit_events, :livemode, :string
    add_column :credit_events, :login, :string
    add_column :credit_events, :mirror, :string
    add_column :credit_events, :payment_id, :string
    add_column :credit_events, :pbctrans, :string
    add_column :credit_events, :rescode, :string
    add_column :credit_events, :sepamount, :string
    add_column :credit_events, :set_amount, :string
    add_column :credit_events, :virtualamount, :string
    add_column :credit_events, :sn, :string
    add_column :credit_events, :status_message, :string
    
    add_index :credit_events, :token
    add_index :credit_events, :user_id
    add_index :credit_events, :pbctrans
  end

  def self.down
    remove_column :credit_events, :token
    remove_column :credit_events, :no_lib
    remove_column :credit_events, :provider 
    remove_column :credit_events, :site_id
    remove_column :credit_events, :commtype
    remove_column :credit_events, :currency
    remove_column :credit_events, :detail
    remove_column :credit_events, :gwtid
    remove_column :credit_events, :livemode
    remove_column :credit_events, :login
    remove_column :credit_events, :mirror
    remove_column :credit_events, :payment_id
    remove_column :credit_events, :pbctrans
    remove_column :credit_events, :rescode
    remove_column :credit_events, :sepamount
    remove_column :credit_events, :set_amount
    remove_column :credit_events, :virtualamount
    remove_column :credit_events, :sn
    remove_column :credit_events, :status_message
    
    remove_index :credit_events, :token
    remove_index :credit_events, :user_id
    remove_index :credit_events, :pbctrans
  end
end
