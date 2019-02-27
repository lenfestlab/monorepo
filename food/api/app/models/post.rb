require 'uri'
require 'cgi'

class Post < ApplicationRecord

  belongs_to :place,
    dependent: :destroy

  validates :published_at, :blurb, :place,
    presence: true

  validates :published_at, uniqueness: { scope: :place_id }

  def image_url
    read_attribute(:image_urls).first
  end

  def url
    Post.ensure_https read_attribute(:url)
  end


  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    [:identifier, :created_at, :updated_at].each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end

    configure :source_key do
      hide
    end
    configure :title do
      hide
    end
    configure :price do
      show
    end
    configure :rating do
      show
    end
    configure :image_urls do
      show
    end

  end

  def admin_name
    blurb.truncate(40)
  end


  ## Serialization
  #

  def self.ensure_https url_string
    return nil unless url_string
    uri = URI(url_string)
    uri.scheme = 'https'
    uri.to_s
  end

  def self.ensure_present string
    string.present? ? string : nil
  end

  def as_json(options = nil)
    super({
      only: [
        :identifier,
        :title,
        :blurb,
        :price,
        :rating,
      ],
      methods: [
        :image_url,
        :url
      ]
    }.merge(options || {}))
  end

end
