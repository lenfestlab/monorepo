class ResourceController < ApplicationController
  include JSONAPI::ActsAsResourceController

  before_action :authenticate_user!, except: %i{ index show }

  def context
    { current_user: current_user }
  end
end
