class ChangePriceCentsInIou < ActiveRecord::Migration
  def self.up
    rename_column :ious, :price_cents, :cents
  end

  def self.down
    rename_column :ious, :cents, :price_cents
  end
end
