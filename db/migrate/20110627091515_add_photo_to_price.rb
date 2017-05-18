class AddPhotoToPrice < ActiveRecord::Migration
  def self.up
    add_column :prices, :photo_file_name, :string
    add_column :prices, :photo_content_type, :string
    add_column :prices, :photo_file_size, :string
  end

  def self.down
    remove_column :prices, :photo_file_name
    remove_column :prices, :photo_content_type
    remove_column :prices, :photo_file_size
  end
end
