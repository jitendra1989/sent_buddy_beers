class AddAttachmentCompanyLogoToCorporate < ActiveRecord::Migration
  def self.up
    add_column :corporates, :company_logo_file_name, :string
    add_column :corporates, :company_logo_content_type, :string
    add_column :corporates, :company_logo_file_size, :integer
    add_column :corporates, :company_logo_updated_at, :datetime
  end

  def self.down
    remove_column :corporates, :company_logo_file_name
    remove_column :corporates, :company_logo_content_type
    remove_column :corporates, :company_logo_file_size
    remove_column :corporates, :company_logo_updated_at
  end
end
