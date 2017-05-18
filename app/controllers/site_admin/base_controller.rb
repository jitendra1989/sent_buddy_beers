class SiteAdmin::BaseController < ApplicationController
  before_filter :require_site_admin

  layout 'site_admin'
end
