require 'uri'
require 'cgi'

class Post < ApplicationRecord

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
    url
    rating
    author
  ], presence: true )

  validates :blurb, uniqueness: true

  before_save :update_cache
  def update_cache
    self.cached_images = photos.as_json
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

  # TODO: drop #images_data

  # TODO: deprecate
  def image_url
    if (image = images.first) && (url = image['url'])
      Post.ensure_https url
    end
  end

  def url
    Post.ensure_https read_attribute(:url)
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
      if %w{ places_summary menu drinks notes }.include?(field_name)
         md.prepend("# #{I18n.t(attr)} \n")
      end
      result = Kramdown::Document.new(md, MD_OPTIONS).to_html.html_safe
      result
    end
  end

  scope :live, ->{ where(live: true) }
  scope :wip, -> { where(live: false) }

  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i[
      identifier
      created_at
      source_key
      images_data
      images
      url
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
      scopes([nil, :live, :wip])
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
    end

    configure :display_starts do
      help "Leave 'display' fields blank to display shortly after saving."
    end
    configure :display_ends do
      help "Set to a past date to hide post indefinitely."
    end

  end

  def admin_name
    blurb.try :truncate, 40
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
    return nil unless url_string
    uri = URI(url_string)
    uri.scheme = 'https'
    uri.to_s.gsub("www2", "www")
  end

  def self.ensure_present string
    string.present? ? string : nil
  end

  def details
    remainder_field_names = %w{ reservations accessibility parking price }
    self.class.html_fields.inject({}) do |agg, attr|
      field_name = attr.to_s.gsub('html_', '')
      field_html = self.send(attr)
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

  # TODO: deprecate
  def price
    prices
  end

  def as_json(options = nil)
    super({
      only: %i[
        identifier
        blurb
        price
        prices
        rating
      ],
      methods: %i[
        image_url
        images
        url
        author
        details
      ]
    }.merge(options || {}))
  end

end
