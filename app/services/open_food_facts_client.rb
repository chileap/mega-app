class OpenFoodFactsClient
  OPEN_FOOD_FACTS_API_URL = "https://world.openfoodfacts.org/api/v0/product/".freeze

  def initialize
    @conn = Faraday.new(url: OPEN_FOOD_FACTS_API_URL) do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end
  end

  def find_product(barcode)
    response = @conn.get("#{barcode}.json")
    JSON.parse(response.body)["product"]
  end
end
