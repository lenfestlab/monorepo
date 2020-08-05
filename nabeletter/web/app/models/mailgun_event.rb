class MailgunEvent < ApplicationRecord
  validates :mg_id, presence: true, uniqueness: true
  validates :payload, :ts, :event, :recipient, presence: true
  belongs_to :edition, optional: true
  belongs_to :subscription, optional: true
end
