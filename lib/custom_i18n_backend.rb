# Prepend current site code name to all translation keys
module I18n
  module Backend
    class SiteScope < Simple
      def translate(locale, key, options = {})
        return nil unless current_site

        case options[:scope]
        when NilClass
          options[:scope] = site_prefix
        when String, Symbol
          options[:scope] = [site_prefix, options[:scope]]
        when Array
          options[:scope] = [site_prefix] + options[:scope]
        end

        super(locale, key, options)
      end


      private

      def current_site
        Thread.current[:current_site]
      end

      def site_prefix
        current_site.code_name
      end
    end
  end
end

# Removed Tolk on 7 Feb 2012
# Make Chain backend compatible with Tolk by adding #translations
# method to it that delegates it to the last (Simple in our case) backend
# module I18n
#   module Backend
#     class TolkCompatibleChain < Chain
#       protected
#       def translations
#         backends.last.send(:translations)
#       end
#     end
#   end
# end
