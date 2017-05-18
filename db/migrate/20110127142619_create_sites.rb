class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :name
      t.string :subdomain

      t.timestamps
    end
    
    #Create default site
    if Site.all.blank?
      site = Site.new(:name => "buddybeers", :subdomain => nil)
      site.save(false)
    end
  end

  def self.down
    drop_table :sites
  end
end
