class CreateBetaBar < ActiveRecord::Migration
  def self.up
    bar = Bar.new(:name => "Hairy Mary's", :address => "Diedenhoferstrasse 5, Berlin 10405, Germany")
    bar.save(false)
    brand = Brand.new(:name => "Becks", :beverage => Beverage.find_by_name("beer"))
    brand.save(false)
    beer = Beer.new(:name => "Original", :brand => brand)
    beer.save(false)
    price = Price.new(:cents => 250, :beer => beer, :bar => bar)
    price.save(false)
    admin = Admin.new(:email => "travisjtodd@me.com", :name => "God", :password => "qwerty", :active => true)
    admin.save(false)
    affiliate = Affiliate.new(:email => "hairy@marys.com", :name => "Mark Gould", :password => "qwerty", :active => true)
    affiliate.save(false)
    affiliate.bars << bar
  end

  def self.down
    bar = Bar.find_by_name("Hairy Mary's")
    bar.destroy() if bar
    brand = Brand.find_by_name_and_beverage_id("Becks", Beverage.find_by_name("beer").id)
    if brand
      brand.destroy
      beer = Beer.find_by_name_and_brand_id("Original", brand.id)
      if beer
        beer.destroy
        price = Price.find_by_cents_and_beer_id_and_bar_id(250, beer.id, bar.id)
        price.destroy if price
      end
    end
  end
end
