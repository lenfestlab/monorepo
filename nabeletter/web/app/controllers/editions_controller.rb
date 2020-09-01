class EditionsController < ApplicationController
  layout false

  def index
  end

  def show
    @edition = Edition.find params[:id]
  end

  protected

  def safe
    params.permit!
  end

end

