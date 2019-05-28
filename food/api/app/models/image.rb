class Image < ApplicationRecord

  has_and_belongs_to_many :posts, touch: true
  has_and_belongs_to_many :categories, touch: true

  has_one_attached :cached_image

  validates(*%i[
    url
  ], presence: true)

  validates_uniqueness_of :url


  ## Cache
  #

  # save associated places to update cached category_ids
  after_save :update_associations
  after_destroy :update_associations
  def update_associations
    self.posts.map &:save!
    self.categories.map &:save!
  end

  after_save :fetch_image
  def fetch_image
    begin
      Rails.logger.info(self.url)
      tempfile = Down.download(self.url, { open_timeout: 2 })
      self.cached_image.attach(
        io: tempfile,
        filename: tempfile.original_filename,
        content_type: tempfile.content_type)
    rescue => ex
      Rails.logger.error(ex)
    end
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

  end

  def admin_name
    [caption, credit, url].compact.join(" - ")
  end

  def preview
    url
  end

  def cached?
    cached_image.attached? && \
      # NOTE: PMN images may return 200 status without image data; #variable?
      # validates data present and correct.
      cached_image.variable?
  end

  def cached_url
    return url unless ENV["DEFAULT_SEND_FILE_CACHE_CONTROL_MAX_AGE"]
    return url unless cached?
    # share routing config w/ ActiveStorage
    ActiveStorage::Current.host =
      Addressable::URI.parse(
        Rails.application.routes.url_helpers.url_for(:root)).site
    # imagemagick '-strip' removes useless meta from image
    #variant = cached_image.variant(strip: true)
    #variant.service_url
    cached_image.service_url
  end

  def as_json
    ActiveModelSerializers::SerializableResource.new(self, {}).as_json
  end

end
