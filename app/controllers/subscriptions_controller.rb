class SubscriptionsController < ApplicationController
  before_action :require_payments_enabled
  before_action :authenticate_user_with_sign_up!
  before_action :require_workspace
  before_action :require_current_workspace_admin, except: [:show]
  before_action :set_plan, only: [:new, :payment, :create, :update]
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  before_action :redirect_to_billing_address, only: [:new]

  layout "checkout", only: [:new, :payment, :create]

  def index
    @billing_address = current_workspace.billing_address
    @payment_processor = current_workspace.payment_processor
    @subscriptions = current_workspace.subscriptions.active.or(current_workspace.subscriptions.past_due).order(created_at: :asc).includes([:customer])
  end

  def show
    redirect_to edit_subscription_path(@subscription)
  end

  # Stripe subscriptions are handled entirely client side
  # We need to create a subscription to render the PaymentElement
  def new
    if Jumpstart.config.stripe?
      payment_processor = current_workspace.add_payment_processor(:stripe)
      if @plan.trial_period_days?
        @client_secret = payment_processor.create_setup_intent.client_secret

      else
        @pay_subscription = payment_processor.subscribe(
          plan: @plan.id_for_processor(:stripe),
          trial_period_days: @plan.trial_period_days,
          payment_behavior: :default_incomplete,
          automatic_tax: {
            enabled: @plan.taxed?
          },
          promotion_code: params[:promo_code]
        )
        @stripe_invoice = @pay_subscription.subscription.latest_invoice
        @client_secret = @pay_subscription.client_secret
      end
    end
  rescue Pay::Stripe::Error => e
    flash[:alert] = e.message
    redirect_to pricing_path
  end

  # Only used by Braintree
  def create
    payment_processor = params[:processor] ? current_workspace.set_payment_processor(params[:processor]) : current_workspace.payment_processor
    payment_processor.payment_method_token = params[:payment_method_token]
    payment_processor.subscribe(
      plan: @plan.id_for_processor(payment_processor.processor),
      trial_period_days: @plan.trial_period_days
    )
    redirect_to root_path, notice: t(".created")
  rescue Pay::ActionRequired => e
    redirect_to pay.payment_path(e.payment.id)
  rescue Pay::Error => e
    flash[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def edit
    # Include current plan even if hidden
    @current_plan = @subscription.plan

    plans = Plan.visible.sorted.or(Plan.where(id: @current_plan.id))
    @monthly_plans = plans.select(&:monthly?)
    @yearly_plans = plans.select(&:yearly?)
  end

  def update
    @subscription.swap @plan.id_for_processor(current_workspace.payment_processor.processor)
    redirect_to subscriptions_path, notice: t(".success")
  rescue Pay::ActionRequired => e
    redirect_to pay.payment_path(e.payment.id)
  rescue Pay::Error => e
    edit # Reload plans
    flash[:alert] = e.message
    render :edit, status: :unprocessable_entity
  end

  def billing_settings
    current_workspace.update(billing_params)
    redirect_to subscriptions_path, notice: t(".billing_settings_updated")
  end

  private

  def billing_params
    params.require(:workspace).permit(:extra_billing_info, :billing_email)
  end

  def require_payments_enabled
    return if Jumpstart.config.payments_enabled?
    flash[:alert] = "Jumpstart must be configured for payments before you can manage subscriptions."
    redirect_back(fallback_location: root_path)
  end

  def set_plan
    @plan = Plan.without_free.find(params[:plan])
  rescue ActiveRecord::RecordNotFound
    redirect_to pricing_path
  end

  def set_subscription
    @subscription = current_workspace.subscriptions.find_by_prefix_id(params[:id])
    redirect_to subscriptions_path if @subscription.nil?
  end

  def redirect_to_billing_address
    if Jumpstart.config.collect_billing_address? && current_workspace.billing_address.nil?
      redirect_to subscriptions_billing_address_path(plan: params[:plan], promo_code: params[:promo_code])
    end
  end
end
