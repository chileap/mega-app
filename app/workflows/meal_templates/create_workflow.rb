class MealTemplates::CreateWorkflow < ApplicationWorkflow
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def call
    if meal_template.save && is_open_api_setup?
      begin
        MealTemplates::GenerateRecipesService.call(meal_template)
      rescue => exception
        meal_template.errors.add(:base, exception.message)
      end
    end

    meal_template
  end

  private

  def meal_template
    @meal_template ||= MealTemplate.new(params)
  end

  def is_open_api_setup?
    Rails.application.credentials.openai_access_token.present?
  end
end
