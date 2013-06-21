Rails.application.config.middleware.use OmniAuth::Builder do
  provider :pocket, API_KEYS["pocket"]#, client_options: { ssl: { ca_path: '/etc/ssl/certs' } }
end
