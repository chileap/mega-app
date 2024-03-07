class Meals::CreateWorkflow < ApplicationWorkflow
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def call
    if meal.save && is_open_api_setup?
      begin
        Meals::GenerateRecipesService.call(meal)
      rescue => exception
        meal.errors.add(:base, exception.message)
      end
    end

    meal
  end

  private

  def meal
    @meal ||= Meal.new(params)
  end

  def is_open_api_setup?
    Rails.application.credentials.openai_access_token.present?
  end
end
