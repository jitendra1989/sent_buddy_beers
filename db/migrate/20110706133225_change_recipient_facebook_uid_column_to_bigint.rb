class ChangeRecipientFacebookUidColumnToBigint < ActiveRecord::Migration
  def self.up
    remove_column :ious, :recipient_facebook_uid
    add_column :ious, :recipient_facebook_uid, :bigint
  end

  def self.down
  end
end
