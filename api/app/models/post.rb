class Post < ApplicationRecord

  validates :lat, :lng, :title, :blurb, :url, :image_urls,
    presence: true

  rails_admin do
    configure(:image_urls, :json) #  https://git.io/fARYJ
  end

end
