class MigrateExistingTokens < ActiveRecord::Migration
  def self.up
    transaction do
      Iou.all(:conditions => {:paid => true, :expired => false, :redeemed => false}).each do |iou|
        iou.read_attribute(:quantity).times do
          begin
            voucher_list = VoucherList.find_or_create_by_bar_id_and_cents_and_currency(iou.bar_id, iou.read_attribute(:price_cents) / iou.read_attribute(:quantity), iou.read_attribute(:currency) || "EUR")
            voucher = Voucher.new(:voucher_list_id => voucher_list.id,
                                  :token => iou.read_attribute(:token).upcase,
                                  :redemption_token => iou.read_attribute(:redemption_token).upcase,
                                  :bar_id => iou.bar_id,
                                  :iou_id => iou.id,
                                  :redeemed => iou.read_attribute(:redeemed),
                                  :cents => iou.read_attribute(:price_cents) / iou.read_attribute(:quantity),
                                  :currency => iou.read_attribute(:currency) || "EUR")
            voucher.save!
          rescue Exception => e
            puts e
            voucher.token = ""
            voucher.save!
          end
        end
      end

      remove_column :ious, :redemption_token
      remove_column :ious, :redeemed
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
