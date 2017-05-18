class CustomViewPaths
  # Preprocess pathsets on the first request
  # pathset generation on every request is supposed to be very costly
  def self.pathsets
    @@pathsets ||= begin
      hash = Hash.new([])
      pathsets = Site.all.map do |site|
        paths = [site_path(site.code_name), fallback_path]
        hash[site.code_name] = ActionView::Base.process_view_paths(paths)
      end
      hash
    end
  end

  def self.site_path(name)
    "app/views/#{name}"
  end

  def self.fallback_path
    "app/views/default"
  end
end
