if ENV["DEEPL_API_KEY"].present?
  DeepL.configure do |config|
    config.auth_key = ENV["DEEPL_API_KEY"]
    config.host = "https://api-free.deepl.com"
  end
end
