class CreateEmailInvitations < ActiveRecord::Migration
  def self.up
    create_table :email_invitations do |t|
      t.string :email
      t.datetime :delivered_at
      t.integer :user_id

      t.timestamps
    end
    
    add_index :email_invitations, :user_id
  end

  def self.down
    drop_table :email_invitations
  end
end
