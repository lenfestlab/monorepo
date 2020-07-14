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
    Rails.logger.info("params.url #{url}")
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
      date_str = body.match(/\d{4}[\/-]\d{2}[\/-]\d{2}/).try(:[], 0)
      published_time = Date.try(:parse, date_str) if date_str
    end
    if !published_time
      matches = body.match(/\d{1,2}[\/-]\d{1,2}[\/-]\d{4}$/)
      date_str = matches.try(:[], 0)
      published_time = Chronic.parse(date_str) if date_str
    end

    data = {
      url: url,
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

