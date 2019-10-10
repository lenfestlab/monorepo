class GuideGroupsController < ApplicationController

  before_action :force_compression

  def index
    data = GuideGroup.all
    render(
      adapter: :json,
      root: 'data',
      meta: { count: data.size },
      json: data,
      each_serializer: GuideGroupSerializer
    )
  end

end
