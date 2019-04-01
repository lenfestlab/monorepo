class User < ApplicationRecord

  has_many :bookmarks, -> { order(created_at: :desc) }

  validates :icloud_id,
    presence: true,
    uniqueness: true


  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i[
      icloud_id
      identifier
      auth_token
      created_at
      updated_at
    ].each do |attr|
      configure attr do
        hide
      end
    end

    %i[
      email
      bookmarks
    ].each do |attr|
      configure attr do
        read_only true
      end
    end

  end

  def admin_name
    %{##{id} (#{(email || "anon")})}
  end


  ## Serialization
  #

  def as_json(options = nil)
    super({
      only: [
        :identifier,
        :icloud_id,
        :email,
        :auth_token
      ],
    }.merge(options || {}))
  end

end
