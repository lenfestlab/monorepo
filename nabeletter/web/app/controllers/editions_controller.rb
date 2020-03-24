class EditionsController < ResourceController
  def update
    if test_params[:attributes][:test] && model = Edition.find(test_params[:id])
      model.deliver(user: current_user)
    end
    super
  end

  private

  def test_params
    params.require(:data).permit(:id, :type, attributes: %i[test])
  end
end
