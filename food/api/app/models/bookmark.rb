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

  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i[
      identifier
      created_at
      updated_at
    ].each do |attr|
      configure attr do
        hide
      end
    end

    %i[
    ].each do |attr|
      configure attr do
        read_only true
      end
    end

  end

  def admin_name
    %{#{user.admin_name} - #{place.name}}
  end

end
