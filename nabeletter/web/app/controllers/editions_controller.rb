class EditionsController < ResourceController
  def update
    if safe_params[:attributes][:test] && edition = Edition.find(safe_params[:id])
      recipients = safe_params[:attributes][:recipients]
      recipients = recipients.present? ? recipients.split(/[\s,]+/) : []
      edition.deliver(recipients: recipients, current_user: current_user)
    end
    super
  end

  private

  def safe_params
    params.require(:data).permit!
  end
end
