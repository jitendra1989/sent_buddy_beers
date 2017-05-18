require "test_helper"

class NotifierTest < ActionMailer::TestCase
  context "voucher_notification" do
    should "send email using iou.site as the current site" do
      site = Factory(:site)
      Thread.current[:current_site] = site

      iou  = Factory(:iou, :site => Site.default)
      assert_not_equal site, iou.site

      template_path_regexp = %r(app/views/buddybeers/notifier/voucher_notification\..+\.haml)
      Notifier.any_instance.expects(:render).once.with{ |options| options[:template].identifier =~ template_path_regexp }.returns("You got mail")

      email = Notifier.voucher_notification(iou).deliver

      assert !ActionMailer::Base.deliveries.empty?
      assert_match /You got mail/, email.encoded
      assert_equal site, Thread.current[:current_site]
    end
  end

  # context "multiple_voucher_notification" do
  #   should "send email using iou.site as the current site" do
  #     site = Factory(:site)
  #     Thread.current[:current_site] = site
  # 
  #     iou  = Factory(:iou, :site => Site.default)
  #     assert_not_equal site, iou.site
  # 
  #     template_path_regexp = %r(app/views/buddybeers/notifier/multiple_voucher_notification\..+\.haml)
  #     Notifier.any_instance.expects(:render).twice.with{ |options| options[:template].identifier =~ template_path_regexp }.returns("You got mail")
  # 
  #     email = Notifier.multiple_voucher_notification(iou).deliver
  # 
  #     assert !ActionMailer::Base.deliveries.empty?
  #     assert_match /You got mail/, email.encoded
  #     assert_equal site, Thread.current[:current_site]
  #   end
  # end
end
