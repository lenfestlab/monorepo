class Delivery < ApplicationRecord
  belongs_to :edition, optional: false
  belongs_to :subscription, optional: false
end
