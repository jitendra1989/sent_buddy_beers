class RenameAdministratorToAdmin < ActiveRecord::Migration
  def self.up
    User.update_all({:type => "Admin"}, {:type => "Administrator"})
  end

  def self.down
    User.update_all({:type => "Administrator"}, {:type => "Admin"})
  end
end
