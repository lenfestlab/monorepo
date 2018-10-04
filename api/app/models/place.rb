class Place < ApplicationRecord

  belongs_to :post,
    # NOTE: omit inverse_of as rec'd by rails_admin docs, else complex form:
    # https://screenshots.brent.is/1538661448.png
    #inverse_of: :places,
    dependent: :destroy,
    touch: true

  validates :lat, :lng,
    presence: true

  rails_admin do

    visible false # hide from nav: https://git.io/fxmGi

    # omit parent Post field from edit/show
    list do
      configure :post do
        show
      end
    end
    edit do
      configure :post do
        hide
      end
    end

    object_label_method :admin_name

    edit do
      [:title, :blurb, :image_url, :radius].each do |attr|
        field attr do
          help "Optional. Only use override the parent Post value above in notifications."
        end
      end
    end
  end


  def admin_name
    "@#{lat},#{lng}"
  end

end
