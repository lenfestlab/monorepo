Bitly.configure do |config|
  config.api_version = 3
  config.access_token = ENV["BITLY_API_KEY"]
end
