class EventsController < BaseController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :destroy_modal, :destroy_recurring]
  # Uncomment to enforce Pundit authorization
  # after_action :verify_authorized
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /events
  def index
    @pagy, @events = pagy(current_workspace.events.sort_by_params(params[:sort], sort_direction))
    # Uncomment to authorize with Pundit
    # authorize @events
    respond_to do |format|
      format.html
      format.turbo_stream
      format.json {
        @events = current_workspace.events.filter_by(params)
      }
    end
  end

  # GET /events/1 or /events/1.json
  def show
    @start_date = params[:start_date]
    @end_date = params[:end_date]
  end

  # GET /events/new
  def new
    @event = Event.new(start_time: Time.current, end_time: Time.current)

    # Uncomment to authorize with Pundit
    # authorize @event
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @event = Events::CreateWorkflow.call(
      params[:sync_services],
      event_params.merge!(created_by: current_user, workspace: current_workspace)
    )

    respond_to do |format|
      if @event.persisted?
        format.html { redirect_to calendars_path, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    @event = Events::UpdateWorkflow.call(@event, event_params.merge!(sync_services: params[:sync_services]))
    respond_to do |format|
      if @event.errors.blank?
        format.html { redirect_to calendars_path, notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy_modal
    @start_date = params[:start_date]
    @end_date = params[:end_date]
  end

  def destroy_recurring
    @event = Events::DestroyRecurringWorkflow.call(event: @event, params: params)

    respond_to do |format|
      if @event.errors.blank?
        format.html { redirect_to calendars_url, status: :see_other, notice: "Event was successfully destroyed." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { redirect_to calendars_url, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event = Events::DestroyWorkflow.call(@event)
    respond_to do |format|
      if @event.errors.blank?
        format.html { redirect_to calendars_url, status: :see_other, notice: "Event was successfully destroyed." }
        format.json { head :no_content }
      else
        format.html { redirect_to calendars_url, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def sync_calendar
    connected_account = current_workspace.connected_accounts.find_by(provider: params[:provider], user: current_user)
    @events = sync_provider_service.new(connected_account).sync_calendar_events(current_workspace, current_user)
    redirect_to calendars_path, notice: "the previous 3 months for now events are successfully imported to our system."
  rescue => err
    redirect_to calendars_path, alert: err.message
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = current_workspace.events.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @event
  rescue ActiveRecord::RecordNotFound
    redirect_to calendars_path, alert: "Event not found"
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.require(:event).permit(
      :workspace_id,
      :created_by_id,
      :name,
      :description,
      :time_zone,
      :start_time,
      :end_time,
      :all_day,
      :repeat
    )

    # Uncomment to use Pundit permitted attributes
    # params.require(:event).permit(policy(@event).permitted_attributes)
  end

  private

  def sync_provider_service
    "Calendars::Events::#{params[:provider].to_s.camelize}Service".constantize
  end
end
