require 'fcm'

namespace :notify do

  desc "every 5 minutes, deliver all scheduled notifications"
  task scheduled: :environment do
    Notification.scheduled.each &:deliver!
  end

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

  desc "request visit status of all eligible apps"
  task visit_checks: :environment do
    Bookmark.visitable.each &:visit_check
  end

end
