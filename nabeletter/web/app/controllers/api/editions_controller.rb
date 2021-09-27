class Api::EditionsController < ResourceController

  def update
    if safe_params[:attributes][:test] && edition = Edition.find(safe_params[:id])
      recipients = safe_params[:attributes][:recipients]
      recipients = recipients.present? ? recipients.split(/[\s,]+/) : []
      channel = safe_params[:attributes][:channel]
      case channel
      when "sms"
        edition.deliver_sms(recipients: recipients)
      else # email
        edition.deliver(recipients: recipients)
      end
    end
    if safe_params[:attributes][:trash] && edition = Edition.find(safe_params[:id])
      edition.trash!
    end
    super
  end

  private

  def safe_params
    params.require(:data).permit!
  end
end
