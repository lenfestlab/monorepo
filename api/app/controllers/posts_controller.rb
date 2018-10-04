class PostsController < ApplicationController

  def index
    posts = Post.all.includes(:places)
    render json: {
      meta: {
        count: posts.count
      },
      data: posts
    }
  end

end

