class BookmarksController < ApplicationController

  before_action :force_compression

  def create
    current_user = self.authenticate!
    place = Place.find_by! identifier: params[:place_id]
    bookmark = Bookmark.find_or_create_by! user: current_user, place: place
    bookmark.reload
    render json: bookmark
  end

  def destroy
    current_user = self.authenticate!
    if (place_identifier = params[:place_id]).present?
      place = Place.find_by! identifier: place_identifier
      bookmark = Bookmark.find_by! user: current_user, place: place
    else
      bookmark = Bookmark.find_by! user: current_user, identifier: params[:id]
    end
    data = { identifier: bookmark.identifier }
    bookmark.destroy!
    render json: data
  end

  def index
    current_user = self.authenticate!
    data =  current_user.bookmarks
    render json: {
      meta: {
        count: data.size
      },
      data: data
    }
  end

end

