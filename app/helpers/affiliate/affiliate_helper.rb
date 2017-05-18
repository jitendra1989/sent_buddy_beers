module Affiliate::AffiliateHelper
  # Only show the next 5 subsequent pages. i.e. <- prev 2,3,4,5,6 next ->
  module AdminPagination
    class LinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
      protected
      def page_number(page)
        unless page == current_page
          link(page, page, :rel => rel_value(page), :title => rel_value(page), :class => "number")
        else
          link(page, page, :rel => rel_value(page), :title => rel_value(page), :class => "current number")
        end
      end
    end
  end
end