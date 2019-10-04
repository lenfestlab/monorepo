require 'uri'
require 'cgi'

class Post < ApplicationRecord

  has_many :notifications,
    inverse_of: :post,
    dependent: :destroy

  has_and_belongs_to_many :places

  # NOTE: "(s)" arg is workaround rails_admin bug, which passes self to nake
  # scope proc on new/edit actions.
  # NOTE: due to bug above, can't preload "images" in as_json, so we proxy
  # the images collection through identical "photos" relation in admin.
  has_and_belongs_to_many :photos, -> (s) {
    order('images_posts.insert_id')
  },
  class_name: "Image",
  join_table: "images_posts",
  foreign_key: "post_id",
  association_foreign_key: "image_id"
  def photo_ids=(ids)
    super([])
    super(ids)
  end

  belongs_to :author

  validates(*%i[
    published_at
    blurb
    rating
    author
  ], presence: true )

  before_save :update_cache
  def update_cache
    self.cached_images = photos.as_json
    self.cached_images_count = cached_images.count
    self.cached_place_names = places.map(&:name).join(" / ")
  end

  # save associated places to update cached association values
  def update_places
    self.places.map &:save!
  end
  after_save :update_places
  after_touch :save

  scope :visible, -> {
    today = Time.zone.today
    where("(display_starts <= ?) OR (display_starts IS NULL)", today)
      .where("(display_ends >= ?) OR (display_ends IS NULL)", today)
      .where(live: true)
  }

  scope :missing_image, -> { where(cached_images_count: 0) }

  # TODO: deprecate
  def image_url
    if (image = images.first) && (url = image['url'])
      Post.ensure_https url
    end
  end

  def append_analytics_params url_string
    return nil if url_string.blank?
    return url_string unless url_string.include?(ENV["UTM_DOMAIN"])
    # NOTE: assumes all post's places are of same name (eg, a chain)
    place_name = places.first.try :name
    params = {
      utm_source: ENV["UTM_SOURCE"],
      utm_medium: ENV["UTM_MEDIUM"],
      utm_campaign: ENV["UTM_CAMPAIGN"],
      utm_term: place_name # ENV["UTM_TERM"]
    }
    # https://git.io/fj95Y
    if url_string.include? "#"
      url_string, fragment = url_string.split "#"
    end
    uri = URI(URI.encode(url_string))
    if (query = uri.query) && (old_params = CGI.parse(query))
      params = old_params.merge!(params)
    end
    uri.query = URI.encode_www_form(params)
    uri.fragment = fragment if fragment
    uri.to_s
  end

  def url_with_analytics
    return nil if url.blank?
    append_analytics_params Post.ensure_https(url)
  end

  def self.md_fields
    %i{
      md_place_summary
      md_menu
      md_drinks
      md_notes
      md_reservations
      md_accessibility
      md_parking
      md_price
    }
  end

  def self.html_fields
    self.md_fields.map {|attr| attr.to_s.gsub('md_','html_').to_sym }
  end


  ## Markdown
  #

  MD_OPTIONS = {auto_ids: false}

  self.md_fields.each do |attr|
    define_method(attr.to_s.gsub('md_','html_')) do
      md = self.send(attr)
      return nil if md.blank?
      if attr == :md_place_summary
        md = %{"#{md.strip}"}
      end
      field_name = attr.to_s.gsub('md_', '')
      if %w{ menu drinks notes }.include?(field_name)
         md.prepend("# #{I18n.t(attr)} \n")
      end
      result = Kramdown::Document.new(md, MD_OPTIONS).to_html.html_safe
      result
    end
  end

  scope :live, ->{ where(live: true) }
  scope :wip, -> { where(live: false) }
  scope :previously_reviewed, -> { where(previously_reviewed: true) }
  scope :previously_unreviewed, -> { where(previously_unreviewed: true) }
  scope :top_25, -> { where(is_2019_top_25: true) }

  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i[
      identifier
      created_at
      source_key
      images
      url
      notifications
      cached_place_names
      url_archived
      cached_images_count
      previously_reviewed
      previously_unreviewed
      is_2019_top_25
    ].each do |attr|
      configure attr do
        hide
      end
    end

    list do
      fields(*%i[
        id
        live
        updated_at
        published_at
        author
        places
        blurb
        rating
      ].concat(Post.md_fields))

      scopes([nil,
              :live,
              :wip,
              :missing_image,
              :previously_unreviewed,
              :previously_reviewed,
              :top_25
      ])

      field :cached_place_names do
        queryable true
        hide
      end

      field :cached_images_count do
        label "Image count"
        filterable true
      end

    end

    configure :blurb do
      rows = ENV["ADMIN_TEXTAREA_ROWS"] || 40
      cols = ENV["ADMIN_TEXTAREA_COLS"] || 80
      html_attributes rows: rows, cols: cols
    end

    Post.md_fields.each do |attr|
      configure attr, :markdown do
        label attr.to_s.gsub('md_','').capitalize.concat(' [MD]')
        html_attributes rows: 4, cols: 80
        help %{Markdown synax: https://commonmark.org/help -- Editor: https://jbt.github.io/markdown-editor }
      end
    end

    configure :photos do
      #inverse_of :posts
      orderable true
      pretty_value do
        bindings[:view].render(
          partial: "images",
          locals: { images: bindings[:object].photos }
        )
      end
    end

    configure :review_url do
      pretty_value do
        url = bindings[:object].url
        bindings[:view].content_tag(:a, url, href: url, target: "_blank")
      end
      export_value do
        value
      end
    end

    configure :display_starts do
      help "Leave 'display' fields blank to display shortly after saving."
    end
    configure :display_ends do
      help "Set to a past date to hide post indefinitely."
    end

    configure :prices_admin do
      label "Prices"
      help "Comma-delimited list of dollar signs, e.g. '$$' or  '$$$,$$$$'"
    end

    export do
      exclude_fields :prices_admin
    end

  end

  def prices_admin= as_string
    as_ints = as_string.split(/[,\s]+/).compact.map(&:length)
    self.prices = (as_ints & Array(0..4)).sort!
  end
  def prices_admin
    prices.map { |i| "$" * i }.join(",")
  end

  def admin_name
    place_name = cached_place_names.try(:split,"/").try(:first)
    preview = blurb.try(:truncate, 40)
    "[#{id}] #{place_name} > #{preview}"
  end

  def review_url= new_value
    self.url = new_value
  end
  def review_url
    url
  end


  ## Serialization
  #

  def images
    self.cached_images
  end

  def self.ensure_https url_string
    return nil if url_string.blank?
    url_string.gsub("www2", "www").gsub("http:", "https:")
  end

  def self.ensure_present string
    string.present? ? string : nil
  end

  def details
    remainder_field_names = %w{ reservations accessibility parking price }
    self.class.html_fields.inject({}) do |agg, attr|
      field_name = attr.to_s.gsub('html_', '')
      field_html = self.send(attr)
      if field_name == "place_summary"
        field_html = ActionController::Base.helpers.strip_tags(field_html)
      end
      if remainder_field_names.include?(field_name)
        remainder = agg["remainder"]
        agg["remainder"] = remainder.present? \
          ? remainder.concat(field_html) \
          : field_html
      else
        agg[field_name] = field_html
      end
      agg
    end
  end

  def as_json
    ActiveModelSerializers::SerializableResource.new(self, {}).as_json
  end

end
