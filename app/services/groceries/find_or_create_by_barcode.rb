class Groceries::FindOrCreateByBarcode < ApplicationService
  attr_reader :barcode

  def initialize(args)
    @barcode = args[:barcode]
  end

  def call
    @grocery = Grocery.find_by(barcode: barcode)
    return @grocery if @grocery.present?

    @grocery = find_by_barcode
    return {} if @grocery.blank?

    @grocery_categories = find_or_create_grocery_categories
    create_grocery
  end

  private

  attr_reader :grocery, :grocery_categories

  def find_by_barcode
    OpenFoodFactsClient.new.find_product(barcode)
  end

  def find_or_create_grocery_categories
    return if grocery["categories_tags"].blank?

    categories = []

    grocery["categories_tags"].each do |category|
      category_name = category.split(":").last
      category = GroceryCategory.find_or_create_by(
        slug: category_name.parameterize,
        name: category_name.titleize
      )
      categories << category
    end
    categories
  end

  def create_grocery
    Grocery.create!(
      name: grocery["product_name"],
      barcode: barcode,
      image_url: grocery["image_url"],
      grocery_categories: grocery_categories,
      payload: grocery.to_json
    )
  end
end
