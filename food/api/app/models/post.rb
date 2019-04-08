require 'uri'
require 'cgi'

class Post < ApplicationRecord

  has_and_belongs_to_many :places

  belongs_to :author

  validates :published_at, :blurb, :url, :rating,
    presence: true

  validates :blurb, uniqueness: true


  # save associated places to update cached association values
  after_save :update_places
  def update_places
    self.places.map &:save!
  end

  def images
    images_data
  end
  def images= data
    clean = data.compact.map { |d| d.slice(*%i[ url caption credit ]) }
    write_attribute( :images_data, clean)
  end
  def image_url # TODO: deprecate
    if (image = images_data.first) && (url = image['url'])
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


  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i[
      identifier
      created_at
      source_key
      images_data
      url
    ].each do |attr|
      configure attr do
        hide
      end
    end

    list do
      fields(*%i[
        id updated_at published_at author places blurb rating
      ].concat(Post.md_fields))
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

    configure :images, :yaml do
      label "Images [YAML]"
      html_attributes rows: 20, cols: 80, wrap: "off"
      help %{TIP: copy/paste edits to validate: http://yaml-online-parser.appspot.com }
      pretty_value do
        data = bindings[:object].images
        bindings[:view].render(
          partial: "post_images_data",
          locals: { data: data }
        )
      end
    end

    configure :review_url do
      pretty_value do
        url = bindings[:object].url
        bindings[:view].content_tag(:a, url, href: url, target: "_blank")
      end
    end
  end

  def admin_name
    blurb.try :truncate, 40
  end

  def review_url
    url
  end


  ## Serialization
  #

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
