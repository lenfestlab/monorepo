module Rack
  module Utils
    if defined?(::Encoding)
      def unescape(s, encoding = Encoding::UTF_8)
        begin
          URI.decode_www_form_component(s, encoding)
        rescue ArgumentError
          URI.decode_www_form_component(URI.encode(s), encoding)
        end
      end
    else
      def unescape(s, encoding = nil)
        begin
          URI.decode_www_form_component(s, encoding)
        rescue ArgumentError
          URI.decode_www_form_component(URI.encode(s), encoding)
        end
      end
    end
    module_function :unescape
  end
end
