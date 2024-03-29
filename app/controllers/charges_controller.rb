class ChargesController < BaseController
  before_action :set_charge

  def show
    respond_to do |format|
      format.pdf {
        send_data @charge.receipt,
          filename: @charge.filename,
          type: "application/pdf",
          disposition: :inline
      }
    end
  end

  def invoice
    respond_to do |format|
      format.pdf {
        send_data @charge.invoice,
          filename: @charge.invoice_filename,
          type: "application/pdf",
          disposition: :inline
      }
    end
  end

  private

  def set_charge
    @charge = current_workspace.charges.find_by_prefix_id(params[:id])
  end
end
