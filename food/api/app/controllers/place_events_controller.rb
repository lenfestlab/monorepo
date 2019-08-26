class PlaceEventsController < ApplicationController

  before_action :force_compression

  def update
    current_user = self.authenticate!
    place_identifier = params["id"]
    place = Place.find_by! identifier: place_identifier
    record = PlaceEvent.find_or_create_by! user: current_user, place: place
    record.update_attributes!(
      params.slice(*%i[
                   last_viewed_at
                   last_entered_at
                   last_exited_at
                   last_visited_at
                   ]).to_hash.compact)
    record.reload # load db-set fields
    render(
      adapter: :json,
      json: record,
    )
  end

  def index
    current_user = self.authenticate!
    data =  current_user.place_events
    render(
      adapter: :json,
      root: 'data',
      meta: { count: data.size },
      json: data,
      each_serializer: PlaceEventSerializer
    )
  end

end
