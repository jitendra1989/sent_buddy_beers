class DeviseCreateCorporates < ActiveRecord::Migration
  def self.up
    create_table(:corporates) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable


      t.timestamps
    end

    add_index :corporates, :email,                :unique => true
    add_index :corporates, :reset_password_token, :unique => true
    # add_index :corporates, :confirmation_token,   :unique => true
    # add_index :corporates, :unlock_token,         :unique => true
    # add_index :corporates, :authentication_token, :unique => true
  end

  def self.down
    drop_table :corporates
  end
end
