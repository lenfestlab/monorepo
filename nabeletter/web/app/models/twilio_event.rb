class TwilioEvent < ApplicationRecord
  validates :sms_id, presence: true, uniqueness: true
  validates :payload, presence: true
  belongs_to :sms_number, optional: true
end
