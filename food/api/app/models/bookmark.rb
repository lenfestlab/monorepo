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


  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i[
      identifier
      created_at
      updated_at
      last_entered_at
      last_exited_at
      last_visited_at
    ].each do |attr|
      configure attr do
        hide
      end
    end

    %i[
      last_saved_at
      last_unsaved_at
      last_notified_at
    ].each do |attr|
      configure attr do
        read_only true
      end
    end

    list do
      scopes([nil, :saved, :unsaved])
    end

  end

  def admin_name
    %{#{user.try(:admin_name)} - #{place.try(:name)}}
  end

end
