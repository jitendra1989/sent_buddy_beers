# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://buddybeers.com"

unless Rails.env.development?
  s3_dir = YAML.load_file(File.join(Rails.root, "config", "s3.yml"))[Rails.env]["bucket"]
  SitemapGenerator::Sitemap.sitemaps_host = "http://s3.amazonaws.com/#{s3_dir}/"
  SitemapGenerator::Sitemap.public_path = 'tmp/'
  SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new
end


SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  
  add '/en/login', :changefreq => 'yearly', :priority => '0.2'
  add '/en/users/sign_in', :changefreq => 'yearly', :priority => '0.2'
  add '/en/users/sign_up', :changefreq => 'yearly', :priority => '0.3'
  add '/en/users/password/new', :changefreq => 'yearly', :priority => '0.1'
  add '/en/privacy', :changefreq => 'monthly', :priority => '0.2'
  add '/en/impressum', :changefreq => 'monthly', :priority => '0.2'
  add '/en/about', :changefreq => 'monthly'
  add '/en/press', :changefreq => 'monthly'
  add '/en/terms', :changefreq => 'monthly', :priority => '0.2'
  add '/en/newbar', :changefreq => 'monthly'
  add bars_path(:locale => :en), :priority => '0.7'
  
  add '/de/login', :changefreq => 'yearly', :priority => '0.2'
  add '/de/users/sign_in', :changefreq => 'yearly', :priority => '0.2'
  add '/de/users/sign_up', :changefreq => 'yearly', :priority => '0.3'
  add '/de/users/password/new', :changefreq => 'yearly', :priority => '0.1'
  add '/de/privacy', :changefreq => 'monthly', :priority => '0.2'
  add '/de/impressum', :changefreq => 'monthly', :priority => '0.2'
  add '/de/about', :changefreq => 'monthly'
  add '/de/press', :changefreq => 'monthly'
  add '/de/agb', :changefreq => 'monthly', :priority => '0.2'
  add '/de/neubar', :changefreq => 'monthly'
  add bars_path(:locale => :de), :priority => '0.7'
  
  Bar.active.find_each do |bar|
    add bar_path(bar, :locale => :en), :priority => '0.7'
    add bar_path(bar, :locale => :de), :priority => '0.7'
  end
  
end
