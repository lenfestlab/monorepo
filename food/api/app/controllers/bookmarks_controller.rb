class BookmarksController < ApplicationController

  before_action :force_compression

  def create
    current_user = self.authenticate!
    post = Post.find_by! identifier: params[:post_id]
    bookmark = Bookmark.find_or_create_by! user: current_user, post: post
    bookmark.reload
    render json: bookmark
  end

  def destroy
    current_user = self.authenticate!
    if (post_identifier = params[:post_id]).present?
      post = Post.find_by! identifier: post_identifier
      bookmark = Bookmark.find_by! user: current_user, post: post
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

