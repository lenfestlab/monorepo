require 'nokogiri'
require 'cgi'

namespace :links do

  task count: :environment do
    Edition.delivered.each do |edition|
      html = edition.body_html
      doc = Nokogiri::HTML(html)
      hrefs = doc.xpath('//a/@href').map(&:value)
      hrefs.map do |href|
        params = CGI::parse(URI::parse(href).query) rescue nil
        if params && (section_name = params["cd4"].first)
          attrs = {
            created_at: Time.zone.now,
            updated_at: Time.zone.now,
            edition_id: edition.id,
            href: href,
            section_name: section_name,
          }
          Link.upsert(attrs, unique_by: :index_links_on_edition_id_and_href)
        end
      end
    end
  end

end
