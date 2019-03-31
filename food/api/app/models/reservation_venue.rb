class ReservationVenue < ApplicationRecord

  has_one :place

  after_save :update_place
  def update_places
    self.place.try :save!
  end


  REQUIRED_ATTRS = %i[
    service
    service_identifier
    service_url
    name
    address_street_with_number
    city state country zip metro phone
    lat lng
  ]

  validates(*REQUIRED_ATTRS, presence: true)

  validates_inclusion_of :service, in: %w( opentable )


  ## Admin
  #

  rails_admin do

    object_label_method :admin_name

    (REQUIRED_ATTRS - %i[
      service
      name
      address_street_with_number
    ]).concat(
      %i[ id created_at updated_at place ])
    .each do |attr|
      configure attr do
        hide
      end
    end

  end

  def admin_anme
    %(#{service}: #{name} @ #{address})
  end


end
