require 'fcm'

namespace :notify do

  desc "request location of all installed apps"
  task locations: :environment do
    fcm = FCM.new(ENV["GCM_API_KEY"])
    response =
      fcm.send_to_topic( "all", {
        "data": {
          "type": "location"
        },
        "content_available": true # https://stackoverflow.com/a/43187302
    })
    ap response
  end

end
