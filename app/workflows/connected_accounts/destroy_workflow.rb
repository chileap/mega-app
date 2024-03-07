class ConnectedAccounts::DestroyWorkflow
  def initialize(connected_account)
    @connected_account = connected_account
  end

  def call
    case @connected_account.provider
    when "google_oauth2"
      Calendars::Webhooks::GoogleOauth2Service.new(@connected_account).delete_webhook(@connected_account.webhook)
    when "microsoft_graph"
      Calendars::Webhooks::MicrosoftGraphService.new(@connected_account).delete_webhook(@connected_account.webhook)
    end

    @connected_account.destroy
  end
end
