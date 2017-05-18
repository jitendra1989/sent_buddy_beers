module PricesHelper
  def has_additional_options?(price)
    price.description.present? or price.drink_type.present? or price.volume.present? or price.photo.file?
  end

end