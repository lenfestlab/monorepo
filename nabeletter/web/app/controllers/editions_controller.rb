class EditionsController < ApplicationController
  layout false

  def index
    @newsletter = Newsletter.find_by_id params[:newsletter_id]
  end

  def show
    @edition = Edition.find params[:id]
  end

  protected

  def safe
    params.permit!
  end

end

