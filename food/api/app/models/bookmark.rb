class Bookmark < ApplicationRecord

  belongs_to :post
  belongs_to :user

  validates :post,
    presence: true,
    uniqueness: { scope: :user }

  validates :user,
    presence: true


  ## Serialization
  #

  def as_json(options = nil)
    super({
      only: [
        :identifier,
      ],
      methods: %i[
        post
      ]
    }.merge(options || {}))
  end

end
