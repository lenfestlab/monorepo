class Notification < ApplicationRecord
  include AASM

  belongs_to :post,
    inverse_of: :notifications

  belongs_to :user,
    optional: true, # http://bit.ly/2Df9QIF
    inverse_of: :notifications

  validates(*%i[
    post
    deliver_at
    state
    title
    body
  ], presence: true)

  validate :lock_once_delivered
  def lock_once_delivered
    return unless delivered?
    attrs = changed_attributes.keys
    ap attrs
    if (attrs & %w{ title body deliver_at user_id }).present?
      errors.add(:base, "locked once delivered")
    end
  end

  after_initialize do
    if new_record?
      self.title ||= "New Opening:"
    end
  end


  ## State machine
  #

  enum state: %i[
    deliverable
    delivered
  ]

  aasm column: :state, enum: true do
    state :deliverable, initial: true
    state :delivered
    event :deliver do
      transitions from: :deliverable, to: :delivered, if: :deliver
    end
  end

  scope :scheduled, -> {
    now = Time.zone.now
    start = 11.minutes.ago now
    deliverable.where("(deliver_at >= ?) AND (deliver_at <= ?)", start, now)
  }


  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i[
      identifier
      created_at
      updated_at
    ].each do |attr|
      configure attr do
        hide
      end
    end

    configure :deliver_at do
      help "To save as draft, set to a past date."
    end

    configure :state do
      read_only true
      help ""
    end

    configure :image_preview do
      read_only true
      help "Post's first image"
      formatted_value do
        if (url = bindings[:object].post.try(:image_url))
          bindings[:view].tag(:img, { src: url, width: "50%"})
        end
      end
    end

    configure :user do
      help "Leave blank to deliver to ALL users."
      # ensure potential target users have gcm_token
      associated_collection_cache_all false
      associated_collection_scope do
        Proc.new { |scope|
          scope = scope.where.not(gcm_token: nil)
        }
      end
    end

  end

  def admin_name
    "[#{id}] #{title}"
  end


  ## APNS
  #

  def deliver
    payload = {
      notification: {
        title: title,
        body: body,
        # http://bit.ly/2KLf8SB
        # > Corresponds to `category` in the APNs payload
        click_action: "announcement",
      },
      data: {
        image_url: post.image_url,
        place_id: post.places.first.identifier, # tap/save/unsave
        post_url: post.url, # read
      },
      # required to triggers service extension:
      # https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension
      mutable_content: true
    }
    ap payload
    fcm = FCM.new(ENV["GCM_API_KEY"])
    response = user.present? \
      ? fcm.send([user.gcm_token], payload) \
      : fcm.send_to_topic("all", payload)
    ap response
    response[:status_code] == 200
  end

end
