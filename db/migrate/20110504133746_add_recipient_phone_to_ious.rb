class AddRecipientPhoneToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :recipient_phone, :string
    
    add_index :ious, :recipient_phone
  end

  def self.down
    remove_column :ious, :recipient_phone
  end
end
