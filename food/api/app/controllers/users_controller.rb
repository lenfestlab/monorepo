class UsersController < ApplicationController

  before_action :force_compression

  def update
    icloud_id = params[:id]
    user = User.find_or_create_by!(icloud_id: icloud_id)
    user.update_attributes! params.slice(:email, :gcm_token).to_hash.compact
    user.reload # ensure db-generated ids loaded
    render json: user
  end

end

