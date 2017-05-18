class CreatePayoutModels < ActiveRecord::Migration
  def self.up
    create_table :payout_models do |t|
      t.integer :bar_id, :null => false
      t.integer :low_cents, :null => false, :default => 0
      t.integer :high_cents
      t.string :currency, :null => false, :default => "EUR"
      t.integer :percent_payout, :null => false

      t.timestamps
    end
    
    add_index :payout_models, :bar_id
    add_index :payout_models, :low_cents
    add_index :payout_models, :high_cents
  end

  def self.down
    drop_table :payout_models
  end
end
