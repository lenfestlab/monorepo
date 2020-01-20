class Edition < ApplicationRecord

  belongs_to :newsletter

  validates :subject,
    presence: true,
    uniqueness: true

  validates :publish_at,
    presence: true,
    uniqueness: true

  validates :publish_at,
    timeliness: { on_or_after: lambda { Date.current }, type: :datetime}

end
