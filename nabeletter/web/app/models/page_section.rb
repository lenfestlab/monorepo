class PageSection < ApplicationRecord

  validates :title,
    presence: true

  belongs_to :page

end
