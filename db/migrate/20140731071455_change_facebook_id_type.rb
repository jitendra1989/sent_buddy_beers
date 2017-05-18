class ChangeFacebookIdType < ActiveRecord::Migration
  def self.up
    change_column :ious, :recipient_facebook_uid, :string
    change_column :group_drinks, :recipient_facebook_uid, :string
  end

  def self.down
    change_column :ious, :recipient_facebook_uid, :integer
    change_column :group_drinks, :recipient_facebook_uid, :integer
  end
end
