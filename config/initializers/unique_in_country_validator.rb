class UniqueInCountryValidator < ActiveModel::EachValidator
  # implement the method called during validation
  def validate_each(record, attribute, value)
    record.errors[attribute] << I18n.t("errors.messages.already_exists") if record.country and record.country.cities.collect{ |c| c.name }.include?(value)
  end
end