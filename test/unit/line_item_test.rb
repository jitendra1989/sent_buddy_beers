require 'test_helper'

class LineItemTest < ActiveSupport::TestCase

  should belong_to(:payment)
  should belong_to(:bar)
  should belong_to(:iou)
  should belong_to(:voucher)

  context "a line item" do
    setup do
      @iou = Factory.create(:iou)
      @line_item = Factory(:line_item, :iou => @iou, :voucher => @iou.vouchers.first)
    end

    should "have a amount as a money object" do
      assert @line_item.amount.present?
      assert @line_item.amount.is_a?(Money)
    end
  end
end
