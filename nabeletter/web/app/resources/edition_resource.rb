class EditionResource < JSONAPI::Resource
  attributes(*%i[subject publish_at body_data body_html body_amp state newsletter_name])

  has_one :newsletter

  def newsletter_name
    @model.newsletter.sender_name
  end


  def self.updatable_fields(context)
    # NOTE: disallows reassigning edition to another newsletter
    super - %i[newsletter]
  end

  def body_html
    body = @model.body_html
    user = @context[:current_user]
    if body && !Rails.env.production? && (tid = ENV["GA_TID"]) && (uid = user.id)
      subs = { "%recipient.tid%" => tid, "%recipient.uid%" => uid }
      re = Regexp.union(subs.keys)
      body.gsub(re, subs)
    else
      body
    end
  end
end
