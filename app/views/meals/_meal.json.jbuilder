json.extract! meal, :id, :name, :bookmark, :serving_for, :ingredients_count, :created_at, :updated_at
json.url meal_url(meal, format: :json)
