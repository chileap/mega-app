class Users::ConnectedAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_connected_account, only: [:destroy]

  def index
    @connected_accounts = current_workspace.connected_accounts
  end

  def create
    @connect_account = current_workspace.connected_accounts.create(connected_account_params.merge(user_id: current_user.id))
    respond_to do |format|
      if @connect_account.persisted?
        format.html { redirect_to user_connected_accounts_path, notice: "#{@connect_account.provider.capitalize} was successfully created." }
        format.json { render json: @connect_account, status: :created, location: @connect_account }
      else
        format.html { redirect_to user_connected_accounts_path, alert: @connect_account.errors.full_messages.join(",") }
        format.json { render json: @connect_account.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @connected_account.destroy
    redirect_to user_connected_accounts_path, status: :see_other
  end

  private

  def set_connected_account
    @connected_account = current_workspace.connected_accounts.find(params[:id])
  end

  def connected_account_params
    params.require(:user_connected_account).permit(
      :email,
      :app_specific_password,
      :provider
    )
  end
end
