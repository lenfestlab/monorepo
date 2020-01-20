namespace :deliver do

  desc "every 5 minutes, deliver all scheduled notifications"
  task scheduled: :environment do
    Edition.scheduled.each &:deliver!
  end

end
