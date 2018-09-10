class Post < ApplicationRecord

  validates :lat, :lng, :title, :blurb, :url, :image_urls,
    presence: true

  rails_admin do
    configure(:image_urls, :json) #  https://git.io/fARYJ
  end

  def location
    { lat: lat, lng: lng }
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

end
