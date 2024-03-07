json.extract! ingredient, :id, :grocery_id, :meal_id, :unit_type, :quantity, :notes, :created_at, :updated_at
json.url ingredient_url(ingredient, format: :json)
