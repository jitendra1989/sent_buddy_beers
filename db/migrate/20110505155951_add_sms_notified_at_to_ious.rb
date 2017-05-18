class AddSmsNotifiedAtToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :sms_notified_at, :datetime
  end

  def self.down
    remove_column :ious, :sms_notified_at
  end
end
