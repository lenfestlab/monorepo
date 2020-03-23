class EditionsController < ApplicationController

  def update
    if test_params[:attributes][:test] && model = Edition.find(test_params[:id])
      model.deliver
    end
    super
  end

  private

  def test_params
    params.require(:data).permit(:id, :type, attributes: [:test])
  end

end
