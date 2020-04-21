class EditionsController < ResourceController
  def update
    if safe_params[:attributes][:test] && model = Edition.find(safe_params[:id])
      model.deliver(user: current_user)
    end
    super
  end

  private

  def safe_params
    params.require(:data).permit(:id, :type, attributes: %i[test])
  end
end
