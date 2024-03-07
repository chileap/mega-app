class GroceriesController < ApplicationController
  before_action :authenticate_user!, expect: [:search]
  before_action :set_grocery, only: [:show, :edit, :update, :destroy]

  # Uncomment to enforce Pundit authorization
  # after_action :verify_authorized
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /groceries
  def index
    @groceries = Grocery.all.search(params[:q])
    render layout: false
  end

  def find_by_barcode
    @grocery = Groceries::FindOrCreateByBarcode.call(barcode: params[:barcode])
    if @grocery.blank?
      render json: {errors: ["Barcode not found"]}, status: :unprocessable_entity
    elsif @grocery.errors.any?
      render json: {errors: @grocery.errors.full_messages}, status: :unprocessable_entity
    else
      render json: @grocery
    end
  end

  def search
    @groceries = Grocery.all.search(params[:q])
    render layout: false
  end

  # GET /groceries/1 or /groceries/1.json
  def show
  end

  # GET /groceries/new
  def new
    @grocery = Grocery.new

    # Uncomment to authorize with Pundit
    # authorize @grocery
  end

  # GET /groceries/1/edit
  def edit
  end

  # POST /groceries or /groceries.json
  def create
    @grocery = Grocery.find_or_create_by(grocery_params)

    # Uncomment to authorize with Pundit
    # authorize @grocery

    respond_to do |format|
      if @grocery.save
        format.html { redirect_to @grocery, notice: "Grocery was successfully created." }
        format.json { render json: @grocery, status: :ok }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @grocery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groceries/1 or /groceries/1.json
  def update
    respond_to do |format|
      if @grocery.update(grocery_params)
        format.html { redirect_to @grocery, notice: "Grocery was successfully updated." }
        format.json { render :show, status: :ok, location: @grocery }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @grocery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groceries/1 or /groceries/1.json
  def destroy
    @grocery.destroy
    respond_to do |format|
      format.html { redirect_to groceries_url, status: :see_other, notice: "Grocery was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_grocery
    @grocery = Grocery.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @grocery
  rescue ActiveRecord::RecordNotFound
    redirect_to groceries_path
  end

  # Only allow a list of trusted parameters through.
  def grocery_params
    params.require(:grocery).permit(:name)

    # Uncomment to use Pundit permitted attributes
    # params.require(:grocery).permit(policy(@grocery).permitted_attributes)
  end
end
