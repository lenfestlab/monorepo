class PagesController < ApplicationController
  layout false
  def show
    @page = Page.find params[:id]
  end
end
