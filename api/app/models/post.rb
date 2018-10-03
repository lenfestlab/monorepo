require 'uri'

class Post < ApplicationRecord

  validates :lat, :lng, :title, :blurb, :url, :image_url,
    presence: true

  def location
    { lat: lat, lng: lng }
  end

  def image_urls
    [
      ensure_https(image_url)
    ]
  end

  def url
    ensure_https(read_attribute(:url))
  end

  def as_json(options = nil)
    super({
      only: [
        :title,
        :blurb,
        :url
      ],
      methods: [
        :image_urls,
        :location
      ]
    }.merge(options || {}))
  end


  private

  def ensure_https url_string
    uri = URI(url_string)
    uri.scheme = 'https'
    uri.to_s
  end

end
