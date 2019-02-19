class Installation < ApplicationRecord

  validates :icloud_id,
    presence: true,
    uniqueness: true


  ## Admin
  #

  rails_admin do

    [:identifier, :auth_token].each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end

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
