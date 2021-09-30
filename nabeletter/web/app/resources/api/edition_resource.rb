class Api::EditionResource < JSONAPI::Resource
  has_one :newsletter
  has_many :links

  attributes(*%i[
             subject
             publish_at
             body_amp
             state
             newsletter_name
             newsletter_lat
             newsletter_lng
             newsletter_source_urls
             newsletter_analytics_name
             newsletter_social_url_facebook
             newsletter_logo_url
             newsletter_timezone
             link_count
             kind
            sms_data_en
            sms_data_es
            email_data_en
            email_data_es
            email_html_en
            email_html_es
             ])


  def newsletter_name
    @model.newsletter.sender_name
  end

  def newsletter_lat
    @model.newsletter.lat
  end
  def newsletter_lng
    @model.newsletter.lng
  end
  def newsletter_source_urls
    @model.newsletter.source_urls
  end
  def newsletter_analytics_name
    @model.newsletter.analytics_name
  end
  def newsletter_social_url_facebook
    @model.newsletter.social_url_facebook
  end
  def newsletter_logo_url
    @model.newsletter.logo_url
  end
  def link_count
    @model.links.count
  end

  def newsletter_timezone
    @model.newsletter.timezone || "Etc/UTC"
  end

  def self.updatable_fields(context)
    # NOTE: disallows reassigning edition to another newsletter
    super - %i[newsletter]
  end

  filter :kind
  filter :state
  filter :newsletter_id

end
