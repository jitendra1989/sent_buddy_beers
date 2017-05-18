s3_creds = YAML.load_file(File.join(Rails.root, "config", "s3.yml"))[Rails.env]
# returns {"bucket"=>"buddybeersdevelopment", "access_key_id"=>"AKIAJEJTK3YYEM2FUA6A", "secret_access_key"=>"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"}

CarrierWave.configure do |config|
  config.cache_dir = "#{Rails.root}/tmp/"
  config.storage = :fog
  config.permissions = 0666
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => s3_creds["access_key_id"],
    :aws_secret_access_key  => s3_creds["secret_access_key"]
  }
  config.fog_directory  = s3_creds["bucket"]
end