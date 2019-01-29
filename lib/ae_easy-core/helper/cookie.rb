module AeEasy
  module Core
    module Helper
      class Cookie
        class << self
          def parse_from_request cookies, cookie_hash = {}
            # Retrieve from hash
            if cookies.is_a? Hash
              cookie_hash.merge! cookies
              return cookie_hash
            end

            # Extract from string
            cookies = cookies.split '; ' if cookies.is_a? String

            # Extract from array
            cookies&.each do |raw_cookie|
              key, value = raw_cookie.split('=', 2)
              cookie_hash[key] = value
            end
            cookie_hash
          end

          def parse_from_response cookies, cookie_hash = {}
            # Retrieve from hash
            if cookies.is_a? Hash
              cookie_hash.merge! cookies
              return cookie_hash
            end
            # Retrieve from String
            cookies = cookies.split '; ' if cookies.is_a? String

            # Extract from array
            info = cookie = expires = key = value = nil
            cookies&.each do |raw_cookie|
              # Extract cookie data
              key_pair = raw_cookie.scan(/(?:;\s+([^\=]+)=([^;]*))/i) || []
              cookie = key_pair.inject(Hash.new){|h,i|h[i[0].to_s.downcase] = i[1]; h}
              cookie[:key], cookie[:value] = raw_cookie.match(/^\s*(?<key>[^\=]+)\=(?<value>[^;]*)/i)&.captures

              # Check cookie expire
              expires = cookie['expires'].nil? ? nil : Time.parse(cookie['expires'])
              if !expires.nil? && Time.now > expires
                cookie_hash.delete cookie[:key]
                next
              end

              # Save cookie
              cookie_hash[cookie[:key]] = cookie[:value]
            end
            cookie_hash
          end

          def update_as_hash request_cookies, response_cookies
            cookie_hash = {}
            parse_from_request request_cookies, cookie_hash
            parse_from_response response_cookies, cookie_hash
            cookie_hash
          end

          def encode_to_header cookie_hash
            cookie_hash.map{|k,v| "#{k}=#{v}"}.join '; '
          end

          def update request_cookies, response_cookies
            cookie_hash = update_as_hash request_cookies, response_cookies
            encode_to_header cookie_hash
          end

          # Compare if cookie is included into base cookie
          def include? base_cookie_hash, cookie_hash
            cookie_hash.each do |key, value|
              return false unless base_cookie_hash.has_key?(key) && base_cookie_hash[key] == value
            end
            true
          end
        end
      end
    end
  end
end
