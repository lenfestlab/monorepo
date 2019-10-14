class Image < ApplicationRecord

  has_and_belongs_to_many :posts, touch: true
  has_and_belongs_to_many :categories, touch: true

  validates(*%i[
    url
  ], presence: true)

  validates_uniqueness_of :url

  has_one_attached :cached_image


  ## Cache
  #

  def cached?
    cached_image.attached? && \
      # NOTE: PMN images may return 200 status without image data; #variable?
      # validates data present and correct.
      cached_image.variable?
  end

  def generate_cachable_url
    return url unless cached?
    # share routing config w/ ActiveStorage
    ActiveStorage::Current.host =
      Addressable::URI.parse(
        Rails.application.routes.url_helpers.url_for(:root)).site
    cached_image.service_url
  end

  before_save :update_cache
  def update_cache
    begin
      Rails.logger.info(self.url)
      tempfile = Down.download(self.url, { open_timeout: 2 })
      self.cached_image.attach(
        io: tempfile,
        filename: tempfile.original_filename,
        content_type: tempfile.content_type)
      self.cached_url = self.generate_cachable_url
    rescue => ex
      Rails.logger.error(ex)
    end
  end

  # reset cache on associations
  after_save :update_associations
  after_destroy :update_associations
  def update_associations
    self.categories.map &:save!
    self.posts.map &:save!
  end


  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i[
      identifier
      created_at
      posts
      categories
      cached_image
      cached_url

      title
      filename
      source_key
    ].each do |attr|
      configure attr do
        hide
      end
    end

    configure :preview do
      read_only true
      pretty_value do
        url = bindings[:object].url
        bindings[:view].tag(:img, { src: url, width: "50%"})
      end
    end

    export do
      exclude_fields :preview
    end

  end

  def admin_name
    [caption, credit, url].compact.join(" - ")
  end

  def preview
    url
  end

  def as_json
    ActiveModelSerializers::SerializableResource.new(self, {}).as_json
  end

end
