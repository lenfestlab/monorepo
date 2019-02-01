class Category < ApplicationRecord

  validates :key, :name,
    presence: true,
    uniqueness: true

  has_many :categorizations
  has_many :places, through: :categorizations

  rails_admin do
    object_label_method :admin_name
    [:identifier, :created_at, :updated_at, :key, :categorizations].each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end
  end

  def admin_name
    name
  end

end