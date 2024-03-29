require 'mailgun-ruby'

module Mailgun
  class Events
    def each(params = nil, &block)
      items = self.get(params).to_h['items']
      until items.empty?
        items.each(&block)
        items = self.next.to_h['items']
      end
    end
  end
end

namespace :events do

  task import: :environment do
    client = Mailgun::Client.new ENV["MAILGUN_API_KEY"]
    endpoint = Mailgun::Events.new(client, "lenfestlab.org")
    types = %w{ opened unsubscribed rejected complained delivered complained }
    env = ENV["RAILS_ENV_ABBR"]
    minutes = Integer(ENV["MAILGUN_MINUTES"] || 30)
    %w{ en }.each do |lang| # TODO: include "es"
      Newsletter.all.each do |newsletter|
        params = {
          event: types.join(" OR "),
          begin: minutes.minutes.ago.to_i,
          ascending: true,
          list: newsletter.list_identifier(lang: lang).gsub("@lenfestlab.org", "")
        }
        ap params
        endpoint.each(params) do |item|
          id = item["id"]
          ts = Time.at item["timestamp"]
          event_name = item["event"]
          email_address = item["recipient"]
          tags = item["tags"].reduce({}) do |hash, tag|
            key, value = tag.split("=")
            hash.update(key => value)
          end
          edition_id = tags["eid"]
          subscription_id = Subscription.find_by_email_address(email_address).try(:id)
          attrs = {
            mg_id: id,
            ts: ts,
            event: event_name,
            recipient: email_address,
            edition_id: edition_id,
            subscription_id: subscription_id,
            payload: item,
          }
          event = MailgunEvent.create_or_find_by attrs
          if event.valid? && event_name == "unsubscribed"
            ap event
            newsletter_id = event.edition.try(:newsletter).try(:id)
            AnalyticsService.new.track(
              user_id: subscription_id,
              event_action: event_name,
              properties: {
                category: "newsletter",
                cd2: edition_id,
                cd3: newsletter_id
              },
              timestamp: ts
            )
          end
        end
      end
    end
  end

end


namespace :stats do

  task import: :environment do
    api_key = ENV["MAILGUN_API_KEY"]
    Edition.normal.delivered.order(:publish_at).each do |edition|
      published_at = edition.publish_at
      start_at = published_at.beginning_of_month.to_i
      end_at = published_at.end_of_month.to_i
      resolution = "month"
      id = edition.id
      tag = "eid=#{id}"
      %w{ delivered }.each do |event|
        url = "https://api:#{api_key}@api.mailgun.net/v3/lenfestlab.org/tags/#{tag}/stats?event=#{event}&resolution=#{resolution}&start=#{start_at}&end=#{end_at}"
        response = HTTParty.get(url)
        Rails.logger.info("parsed_response #{response.parsed_response}")
        data = response.parsed_response
        total = data["stats"][0][event]["total"] rescue nil
        if total
          edition.update("stat_#{event}": total)
        end
      end
    end
  end

end

