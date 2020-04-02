class ResourceController < ApplicationController
  include JSONAPI::ActsAsResourceController

  before_action do |controller|
    origin = request.headers['origin']
    unless origin && origin.include?(ENV["EDITOR_HOST"])
      controller.send :authenticate_user!
    end
  end
end
