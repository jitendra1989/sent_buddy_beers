class AddNullToIouFields < ActiveRecord::Migration
  
  # Postgresql required null set to false to ensure all defaults are set for prexisting entries.
  # Plus, it just seems like good practice that if you want a default you make sure it can't be null.
  
  def self.up
    #change_column :ious, :virtual,    :boolean, :default => false,  :null => false # Set in previous migration
    change_column :ious, :expired,     :boolean, :default => false,  :null => false
    change_column :ious, :price_cents, :integer, :default => 0,      :null => false
    change_column :ious, :notified,    :boolean, :default => false,  :null => false
    change_column :ious, :paid,        :boolean, :default => false,  :null => false
    change_column :ious, :redeemed,    :boolean, :default => false,  :null => false
    change_column :ious, :status,      :string,  :default => "sent", :null => false
  end

  def self.down
    change_column :ious, :expired,     :boolean, :default => false,  :null => true
    change_column :ious, :price_cents, :integer, :default => 0,      :null => true
    change_column :ious, :notified,    :boolean, :default => false,  :null => true
    change_column :ious, :paid,        :boolean, :default => false,  :null => true
    change_column :ious, :redeemed,    :boolean, :default => false,  :null => true
    change_column :ious, :status,      :string,  :default => "sent", :null => true
  end
end
