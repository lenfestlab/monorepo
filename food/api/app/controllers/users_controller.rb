class UsersController < ApplicationController

  before_action :force_compression

  def update
    icloud_id = params[:id]
    installation = User.find_or_create_by!(icloud_id: icloud_id)
    if email = params[:email]
      installation.update_attributes!(email: email)
    end
    installation.reload # ensure db-generated ids loaded
    render json: installation
  end

end

