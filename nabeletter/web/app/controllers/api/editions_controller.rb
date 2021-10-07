class Api::EditionsController < ResourceController

  def update
    if safe_params[:attributes][:test] && edition = Edition.find(safe_params[:id])
      recipients = safe_params[:attributes][:recipients]
      recipients = recipients.present? ? recipients.split(/[\s,]+/) : []
      channel = safe_params[:attributes][:channel]
      lang = safe_params[:attributes][:lang]
      DeliveryService.new.deliver_to(
        recipients: recipients,
        edition: edition,
        channel: channel,
        lang: lang,
        )
    end
    if (trash = safe_params[:attributes][:trash]).present?  &&\
       edition = Edition.find(safe_params[:id])
      case trash
      when "trash"
        edition.trash!
      when "untrash"
        edition.draft!
      end
    end
    super
  end

  private

  def safe_params
    params.require(:data).permit!
  end
end
