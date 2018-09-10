class PostsController < ApplicationController

  def index
    posts = Post.all
    render json: {
      meta: {
        count: posts.count
      },
      data: posts
    }
  end

end

