require 'uri'
require 'cgi'

class Post < ApplicationRecord

  has_and_belongs_to_many :places

  belongs_to :author,
    dependent: :destroy


  validates :published_at, :blurb,
    presence: true

  # save associated places to update cached association values
  after_save :update_places
  def update_places
    self.places.map &:save!
  end

  def image_url
    Post.ensure_https (read_attribute(:image_urls) || []).first
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

  MD_OPTIONS = {}

  self.md_fields.each do |attr|
    define_method(attr.to_s.gsub('md_','html_')) do
      md = self.send(attr)
      return nil unless md
      Kramdown::Document.new(md, MD_OPTIONS).to_html.html_safe
    end
  end


  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i{
      identifier
      created_at
      updated_at
      source_key
      title
      image_urls
    }.each do |attr|
      configure attr do
        hide
      end
    end

    %i{
      price
      rating
    }.each do |attr|
      configure attr do
        read_only true
        show
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
      end
    end

  end

  def admin_name
    blurb.try :truncate, 40
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

  def details_html
    md = Post.md_fields.reduce([]) { |agg, attr|
      attr_head = I18n.t(attr)
      attr_value = self.send(attr)
      section =
        if attr_value.blank?
          []
        elsif attr == :md_place_summary
          ["> #{attr_value}"]
        elsif attr_value
          ["## #{attr_head}", attr_value]
        else
          []
        end
      agg.concat(section).flatten.compact
    }.join("\n\n")
    Kramdown::Document.new(md, MD_OPTIONS).to_html.html_safe
  end

  def as_json(options = nil)
    super({
      only: %i[
        identifier
        title
        blurb
        price
        rating
      ],
      methods: %i[
        image_url
        url
        author
        details_html
      ]
    }.merge(options || {}))
  end

end
