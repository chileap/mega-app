class ListsController < BaseController
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  def index
    @lists = current_workspace.lists
  end

  def show
  end

  def new
    @list = current_workspace.lists.new
  end

  def edit
  end

  def create
    @list = current_workspace.lists.new(list_params.merge!(created_by: current_user))

    respond_to do |format|
      if @list.save
        format.html { redirect_to @list, notice: "List was successfully created." }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream
            .prepend(:flash, partial: "shared/flash", locals: {alert: @list.errors.full_messages.to_sentence})
        }
      end
    end
  end

  def update
    respond_to do |format|
      if @list.update(list_params)
        format.html { redirect_to @list, notice: "List was successfully updated." }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @list.destroy
    respond_to do |format|
      format.html { redirect_to lists_path, notice: "List was successfully destroyed." }
      format.turbo_stream
    end
  end

  private

  def set_list
    @list = current_workspace.lists.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to lists_path
  end

  def list_params
    params.require(:list).permit(:name)
  end
end
