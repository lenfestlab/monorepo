class Category < ApplicationRecord

  validates :name,
    presence: true

  validates :name, uniqueness: { scope: :is_cuisine }

  has_many :categorizations, dependent: :destroy
  has_many :places, through: :categorizations

  # see related notes in Post
  has_and_belongs_to_many :photos, -> (s) {
    order('categories_images.insert_id')
  },
  class_name: "Image",
  join_table: "categories_images",
  foreign_key: "category_id",
  association_foreign_key: "image_id"
  def photo_ids=(ids)
    super([])
    super(ids)
  end

  # TODO: restore once craving guides' images imported
  # validates :photos,
    # presence: true,
    # unless: Proc.new { |r| r.is_cuisine }

  validates :display_starts,
    presence: true,
    unless: Proc.new { |c| c.is_cuisine }

  after_initialize do
    if new_record?
      self.display_starts ||= Time.zone.now
    end
  end

  # save associated places to update cached category_ids
  after_save :update_places
  after_destroy :update_places
  def update_places
    self.places.map &:save!
  end

  before_save :update_cache
  def update_cache
    self.cached_images = self.photos.as_json
  end
  def images
    self.cached_images
  end

  def image_url
    if (image = images.first) && (url = image["url"])
      Post.ensure_https url
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
      categorizations
      image_url
      key
    }.each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end

    configure :photos do
      orderable true
      pretty_value do
        bindings[:view].render(
          partial: "images",
          locals: { images: bindings[:object].photos }
        )
      end
    end

    list do
      scopes([nil, :cuisines, :guides])
      configure :photos do
        hide
      end
      configure :image_url do
        pretty_value do
          url = bindings[:object].image_url
          bindings[:view].tag(:img, { src: url, width: "50%"})
        end
      end
    end

    configure :display_starts do
      help "Required. Set to a future date to postpone/embargo display."
    end
    configure :display_ends do
      help "Optional. Leave blank to display indefinitely."
    end

  end

  def admin_name
    name
  end


  ## Filters
  #

  scope :cuisine, -> (value) {
    if value.present?
      where(is_cuisine: value)
    end
  }

  scope :cuisines, -> {
    where(is_cuisine: true)
  }

  scope :guides, -> {
    where(is_cuisine: false)
  }

  scope :visible, -> {
    today = Time.zone.today
    where("(display_starts <= ?) OR (display_starts IS NULL)", today)
      .where("(display_ends >= ?) OR (display_ends IS NULL)", today)
  }

  ## Serialization
  #

  def as_json(options = nil)
    super({
      only: %i[
        identifier
        is_cuisine
        name
        description
        display_starts
        display_ends
      ],
      methods: %i[
        image_url
      ]
    }.merge(options || {}))
  end

end
