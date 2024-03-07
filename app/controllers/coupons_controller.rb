class CouponsController < BaseController
  before_action :set_coupon, only: [:show]

  # Uncomment to enforce Pundit authorization
  # after_action :verify_authorized
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /coupons
  def index
    @pagy, @coupons = pagy(Coupon.all.filter_by(params).sort_by_params(params[:sort], sort_direction))

    # Uncomment to authorize with Pundit
    # authorize @coupons
  end

  # GET /coupons/1 or /coupons/1.json
  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_coupon
    @coupon = Coupon.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @coupon
  rescue ActiveRecord::RecordNotFound
    redirect_to coupons_path
  end
end
