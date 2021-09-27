class Api::SubscriptionResource < JSONAPI::Resource
  attributes(
    *%i[
      channel
      email_address
      phone
      e164
      subscribed_at
      unsubscribed_at
      name_first
      name_last],
  )

  has_one :newsletter

  def self.creatable_fields(context)
    fields = super - %i[unsubscribed_at]
    fields
  end

  def self.updatable_fields(context)
    # disallow re-assigning subsciption to another newsletter
    super - %i[newsletter]
  end

  filter :channel
  filter :email_address, apply: ->(records, value, _options) {
    records.where "email_address LIKE ?", "%#{value[0]}%"
  }
  filter :e164, apply: ->(records, value, _options) {
    records.where "e164 LIKE ?", "%#{value[0]}%"
  }
  filter :name_last, apply: ->(records, value, _options) {
    records.where "name_last LIKE ?", "%#{value[0]}%"
  }

end
