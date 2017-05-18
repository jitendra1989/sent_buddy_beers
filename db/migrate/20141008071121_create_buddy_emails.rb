class CreateBuddyEmails < ActiveRecord::Migration
  def self.up
    create_table :buddy_emails do |t|
      t.string :email
      t.references :emailable, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :buddy_emails
  end
end
