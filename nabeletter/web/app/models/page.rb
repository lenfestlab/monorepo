class Page < ApplicationRecord

  belongs_to :newsletter

  has_many :page_sections

  def sections
    all = page_sections.order("created_at")
    all_ids = all.map &:id
    ordered_ids = self.ordered_section_ids & all_ids
    union = ordered_ids | all_ids
    sorted = union.map do |id|
      all.find {|s| s.id == id}
    end
    sorted.as_json(only: %i[ id title body hidden ])
  end

  def sections= ordered_sections
    ordered_sections_ids =  ordered_sections.map {|i| i["id"]}
    self.update! ordered_section_ids: ordered_sections_ids
  end

  def last_updated_at
    [updated_at].concat(page_sections.map(&:updated_at)).max.iso8601
  end

  def newsletter_logo_url
    newsletter.logo_url
  end
  def newsletter_name
    newsletter.sender_name
  end
  def newsletter_social_url_facebook
    newsletter.social_url_facebook
  end
  def newsletter_analytics_name
    newsletter.analytics_name
  end
  def newsletter_id
    newsletter.id
  end

  def as_json(options)
    super(methods: %i{ 
          last_updated_at
          newsletter_name
          newsletter_logo_url 
          newsletter_social_url_facebook
          newsletter_analytics_name
          newsletter_id
          })
  end

end
