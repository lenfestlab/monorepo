class Categorization < ApplicationRecord

  belongs_to :place, touch: true
  belongs_to :category, touch: true

  validates :place, :category, presence: true
  validates :place, uniqueness: { scope: :category }

  rails_admin do
    object_label_method :admin_name
    [:identifier, :created_at, :updated_at].each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end

  end

  def admin_name
    [category.name, place.name].join("-")
  end

end
