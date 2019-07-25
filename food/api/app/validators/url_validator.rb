# https://coderwall.com/p/ztig5g/validate-urls-in-rails
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    record.errors[attribute] << (options[:message] || "must be a complete & valid URL") unless url_valid?(value)
  end

  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end
end
