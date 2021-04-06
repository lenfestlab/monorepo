class Page < ApplicationRecord

  validates :title,
    presence: true

  has_many :page_sections

  def sections
    page_sections.order("created_at").as_json(only: %i[ id title body ])
  end

end
