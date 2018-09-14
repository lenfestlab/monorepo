require 'uri'

class Post < ApplicationRecord

  validates :lat, :lng, :title, :blurb, :url, :image_urls,
    presence: true

  rails_admin do
    configure(:image_urls, :json) #  https://git.io/fARYJ
  end

  def location
    { lat: lat, lng: lng }
  end

  def image_urls
    read_attribute(:image_urls).map { |url| ensure_https(url) }
  end

  def url
    ensure_https(read_attribute(:url))
  end

  def as_json(options = nil)
    super({
      only: [
        :title,
        :blurb,
        :url,
        :image_urls
      ],
      methods: [
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
