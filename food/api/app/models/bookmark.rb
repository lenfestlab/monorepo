class Bookmark < ApplicationRecord

  belongs_to :place
  belongs_to :user

  validates :place,
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
        place
      ]
    }.merge(options || {}))
  end

end
