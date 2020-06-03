require "open_graph_reader"

class Error < StandardError
  def initialize(msg = "Unknown")
    super
  end
end

class ArticlesController < ApplicationController
  layout false

  def index
    url = safe[:url]
    object = OpenGraphReader.fetch! url
    og = object.og
    data = {
      url: og.url,
      title: og.title,
      description: og.description,
      published_time: object.try(:article).try(:published_time),
      site_name: og.site_name,
      image: og.image.try(:url)
    }
    render json: data
  end

  protected

  def safe
    params.permit([:url])
  end

end

