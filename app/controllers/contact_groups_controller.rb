class ContactGroupsController < BaseController
  before_action :set_contact_group, only: [:show, :edit, :update, :destroy]

  def index
    @contact_groups = current_workspace.contact_groups
  end

  def show
  end

  def new
    @contact_group = current_workspace.contact_groups.new
  end

  def edit
  end

  def create
    @contact_group = current_workspace.contact_groups.new(contact_group_params.merge!(created_by: current_user))

    respond_to do |format|
      if @contact_group.save
        format.html { redirect_to @contact_group, notice: "Contact Group was successfully created." }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream
            .prepend(:flash, partial: "shared/flash", locals: {alert: @contact_group.errors.full_messages.to_sentence})
        }
      end
    end
  end

  def update
    respond_to do |format|
      if @contact_group.update(contact_group_params)
        format.html { redirect_to @contact_group, notice: "Contact Group was successfully updated." }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contact_group.destroy
    respond_to do |format|
      format.html { redirect_to contact_groups_path, notice: "Contact Group was successfully destroyed." }
      format.turbo_stream
    end
  end

  private

  def set_contact_group
    @contact_group = current_workspace.contact_groups.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to contact_groups_path
  end

  def contact_group_params
    params.require(:contact_group).permit(:name)
  end
end
