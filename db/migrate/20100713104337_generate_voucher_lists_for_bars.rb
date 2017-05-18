class GenerateVoucherListsForBars < ActiveRecord::Migration
  def self.up
    transaction do
      Price.all.each do |price|
        VoucherList.find_or_create_by_bar_id_and_cents_and_currency(price.bar_id, price.cents, price.currency || "EUR")
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end