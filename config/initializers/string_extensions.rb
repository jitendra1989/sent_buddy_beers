require "digest/sha1"

class String
  def self.tokenize(length = 40)
    Digest::SHA1.hexdigest(UUID.new.generate.chomp.gsub("-", "")).first(length).upcase
  end
end