Rails.application.config.middleware.use OmniAuth::Builder do
  provider :pocket, API_KEYS["pocket"]
end
