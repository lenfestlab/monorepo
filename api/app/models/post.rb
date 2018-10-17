require 'uri'
require 'cgi'

class Post < ApplicationRecord

  has_many :places
    # NOTE: omit inverse_of as rec'd by rails_admin docs, else complex form:
    # https://screenshots.brent.is/1538661448.png
    #inverse_of: :post

  validates :title, :blurb, :url, :image_url,
    presence: true

  accepts_nested_attributes_for :places,
    allow_destroy: true

  def location
    place = places.first
    { lat: place.lat, lng: place.lng }
  end

  def image_url
    Post.ensure_https read_attribute(:image_url)
  end

  # NOTE: deprecated
  def image_urls
    [
      image_url
    ]
  end

  def url
    secure_url = Post.ensure_https read_attribute(:url)
    Post.append_analytics_params secure_url
  end

  def as_json(options = nil)
    super({
      only: [
        :title,
        :blurb,
        :url,
      ],
      methods: [
        :identifier,
        :image_url,
        :image_urls, # NOTE: deprecated
        :location # NOTE: deprecafted
      ]
    }.merge(options || {}))
  end

  def self.default_trigger_radius
    ENV["DEFAULT_TRIGGER_RADIUS"].to_i || 100
  end

  def self.ensure_https url_string
    return nil unless url_string
    uri = URI(url_string)
    uri.scheme = 'https'
    uri.to_s
  end

  def self.append_analytics_params url_string
    return nil unless url_string
    params = {
      utm_source: ENV["UTM_SOURCE"],
      utm_medium: ENV["UTM_MEDIUM"],
      utm_campaign: ENV["UTM_CAMPAIGN"],
      utm_term: ENV["UTM_TERM"]
    }
    uri = URI(url_string)
    if (query = uri.query) && (old_params = CGI.parse(query))
      params = old_params.merge!(params)
    end
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  rails_admin do

    configure :identifier do
      hide
    end

    configure :radius do
      help "Meters. Optional, if blank defaults to #{Post.default_trigger_radius}"
    end

  end

end
