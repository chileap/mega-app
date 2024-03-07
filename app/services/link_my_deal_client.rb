class LinkMyDealClient
  LINK_MY_DEAL_API_URL = "https://feed.linkmydeals.com/getOffers/"
  LINK_MY_DEAL_API_KEY = Rails.application.credentials.link_my_deal_api_key

  def initialize
    @conn = Faraday.new(url: LINK_MY_DEAL_API_URL) do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end
  end

  def get_offers
    last_extract = CouponImporter.first&.last_extracted_at&.to_i || Time.now.beginning_of_day.to_i

    response = @conn.get do |req|
      req.params["API_KEY"] = LINK_MY_DEAL_API_KEY
      req.params["format"] = "json"
      req.params["last_extract"] = last_extract
      req.params["incremental"] = 1
      req.params["off_record"] = 1
    end

    JSON.parse(response.body)
  end
end
