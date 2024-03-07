class ContactsController < BaseController
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :edit_popover]

  def index
    @contacts = current_workspace.contacts.filter_by(params)
    @contact_groups = current_workspace.contact_groups
    @contact_group = nil

    if params[:contact_group_id].present?
      @contact_group = current_workspace.contact_groups.find(params[:contact_group_id])
    end

    respond_to do |format|
      format.html
      format.turbo_stream
      format.json
    end
  end

  def show
  end

  def new
    @contact = current_workspace.contacts.new(contact_group_id: params[:contact_group_id])
  end

  def edit
  end

  def create
    @contact = current_workspace.contacts.new(contact_params.merge!(created_by: current_user))

    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: "Contact was successfully created." }
        format.turbo_stream {
          turbo_stream.replace("contact_group_sidebar", partial: "contacts/contact_group_sidebar", locals: {contacts: current_workspace.contacts})
        }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream
            .prepend(:flash, partial: "shared/flash", locals: {alert: @contact.errors.full_messages.to_sentence})
        }
      end
    end
  end

  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: "Contact was successfully updated." }
        format.turbo_stream
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream
            .prepend(:flash, partial: "shared/flash", locals: {alert: @contact.errors.full_messages.to_sentence})
        }
      end
    end
  end

  def destroy
    @contact.destroy
    respond_to do |format|
      if params[:from].present? && params[:from] == "calendar"
        format.html { redirect_to calendars_url, notice: "Contact was successfully destroyed." }
      else
        format.html { redirect_to contacts_path, notice: "Contact was successfully destroyed." }
        format.turbo_stream
      end
    end
  end

  private

  def set_contact
    @contact = current_workspace.contacts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to contacts_path
  end

  def contact_params
    params.require(:contact).permit(
      :name,
      :first_name,
      :last_name,
      :company_name,
      :website_url,
      :country_code,
      :phone_number,
      :address,
      :contact_group_id
    )
  end
end
