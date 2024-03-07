OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.openai_access_token
  config.organization_id = Rails.application.credentials.openai_organization_id
end
