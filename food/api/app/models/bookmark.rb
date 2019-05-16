class Bookmark < ApplicationRecord

  belongs_to :place
  belongs_to :user

  validates :place,
    presence: true,
    uniqueness: { scope: :user }

  validates :user,
    presence: true

  scope :saved, -> {
    where(%{
      last_unsaved_at IS NULL OR
          (last_unsaved_at IS NOT NULL AND last_unsaved_at < last_saved_at) })
  }
  scope :unsaved, -> {
    where(%{
      last_unsaved_at IS NOT NULL AND
          last_unsaved_at > last_saved_at })
  }

  scope :visitable, -> {
    now = Time.zone.now
    duration = Integer(ENV["DEFAULT_VISIT_DURATION"] || 10)
    before = duration.minutes.ago now
    where("last_entered_at > COALESCE(last_exited_at, 'epoch')")  # hasn't yet exited
      .where("last_entered_at > COALESCE(last_visited_at, 'epoch')") # no visit recorded yet
      .where("last_entered_at < ?", before) # entered 15+ min ago
      .where("last_entered_at > ?", 1.hour.ago(now)) # check window is 1h
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

    %i[
      last_saved_at
      last_unsaved_at
      last_entered_at
      last_exited_at
      last_visited_at
      last_notified_at
    ].each do |attr|
      configure attr do
        read_only true
      end
    end

    list do
      scopes([nil, :saved, :unsaved, :visitable])
    end

  end

  def admin_name
    %{#{user.admin_name} - #{place.name}}
  end


  ## APNS
  #

  def visit_check
    payload = {
      data: {
        type: "visit_check",
        place_id: self.place.identifier
      },
      content_available: true # https://stackoverflow.com/a/43187302
    }
    ap payload
    fcm = FCM.new(ENV["GCM_API_KEY"])
    response = fcm.send([user.gcm_token], payload)
    ap response
    response[:status_code] == 200
  end

end
