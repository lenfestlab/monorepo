class BookmarksController < ApplicationController

  before_action :force_compression

  def index
    current_user = self.authenticate!
    data =  current_user.bookmarks.saved
    render(
      adapter: :json,
      root: :data,
      meta: { count: data.size },
      json: data,
      each_serializer: BookmarkSerializer
    )
  end

  def show
    current_user = self.authenticate!
    place = Place.find_by! identifier: params[:place_id]
    bookmark = current_user.bookmarks.saved.where(place: place).first
    render(
      adapter: :json,
      json: bookmark,
    )
  end

  def update
    current_user = self.authenticate!
    place = Place.find_by! identifier: params[:place_id]
    bookmark = Bookmark.find_or_create_by! user: current_user, place: place
    bookmark.update_attributes!(
      params.slice(*%i[
        last_saved_at
        last_unsaved_at
        last_entered_at
        last_exited_at
        last_visited_at
      ]).to_hash.compact)
    bookmark.reload # load db-set fields
    render(
      adapter: :json,
      json: bookmark,
    )
  end

end

