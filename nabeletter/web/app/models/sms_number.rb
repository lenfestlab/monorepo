class SmsNumber < ApplicationRecord

  belongs_to :newsletter
  enum env: %i[dev prod]
  enum lang: %i[en es]

  validates :e164,
    presence: true,
    uniqueness: true,
    phone: true

  validates :newsletter,
    presence: true,
    uniqueness: { scope: [:env, :lang] }

end
