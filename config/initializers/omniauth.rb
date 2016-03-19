OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, "1686327871634430", "d057d40574cb75d2226269215ab2f44b"
end