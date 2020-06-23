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
    response = HTTParty.get url
    raise(StandardError, response["errors"]) unless response.success?
    body = response.body
    OpenGraphReader.parse!(body)
    object = OpenGraphReader.fetch! url
    og = object.og

    published_time = object.try(:article).try(:published_time)
    if !published_time
      # <meta property="article:published_time" content="2020-06-22T16:52:31+00:00" />
      doc = Nokogiri::HTML(body)
      meta = doc.xpath('//meta[@property="article:published_time"]').first
      content = meta["content"] if meta
      published_time = Date.parse(content) if content
    end
    if !published_time
      date_str = body.match(/\d{4}[\/-]\d{2}[\/-]\d{2}/)[0]
      published_time = Date.try(:parse, date_str)
    end

    data = {
      url: og.url,
      title: og.title,
      description: og.description,
      published_time: published_time,
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

