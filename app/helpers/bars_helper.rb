module BarsHelper
  def google_maps_link_for(bar)
    "http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=#{[bar.address.gsub(" ", "+"), bar.city.name, bar.country.printable_name].join("+")}"
  end

  def bars_to_map_markers(bars)
    Array(bars).map do |bar|
      bar_hash = bar.as_json(:only => [:lat, :lng, :address, :name])
      # Can't merge it directly because of root in JSON...
      bar_hash["bar"].merge!(:url => bar_url(:id => bar.friendly_id || bar.id))
      bar_hash
    end.to_json
  end

  def beers_in_price_range(amount, bar)
    @prices = Price.find_all_by_cents_and_bar_id(amount, bar.id)
    @beers = []
    @prices.each do |price|
      @beers << price.name
    end
    return @beers.join(", ")
  end
  
  def has_drink_specials?(bar)
    t(bar.prices.discounted.present? ? "global.affirmative" : "global.negative").upcase
  end
  
  def price_range_for(bar)
    unless bar.prices.blank? #really this is just because of fixtures in tests
      prices = bar.prices.sort{|t1,t2| t1.total <=> t2.total}
      [number_to_currency(prices.first.total.to_f, :unit => prices.first.amount.currency.symbol), 
      number_to_currency(prices.last.total.to_f, :unit => prices.last.amount.currency.symbol)].join("&ndash;").html_safe
    end
  end
  
  def carlsberg_beer_name_for(index)
    case index
    when 0
      t("bars.form.form.single_carlsberg")
    when 1
      t("bars.form.form.carlsberg_deal")
    when 2
      t("bars.form.form.other_drink")
    end
  end
  
  def carlsberg_class_name(index)
    case index
    when 0
      "single_carlsberg"
    when 1
      "multi_carlsberg"
    when 2
      "other_drink"
    end
  end
end
