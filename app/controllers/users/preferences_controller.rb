class Users::PreferencesController < ApplicationController
  before_action :authenticate_user!

  def edit
  end

  def update
    current_user.update_preferences(params[:view_options])
    redirect_to edit_user_preferences_path, notice: "Preferences updated"
  end
end
