module AeEasy
  module Core
    module Helper
      # Helper used for lower level cookie management.
      class Cookie
        class << self
          # Parse request cookies on different formats.
          #
          # @param [String,Hash,Array] cookies Cookies to parse.
          # @param [Hash] cookie_hash ({}) External hash to store parsed cookies.
          #
          # @return [Hash]
          #
          # @example Parse from string.
          #   parse_from_request 'aaa=111; bbb=222'
          #   # => {'aaa' => 111, 'bbb' => 222}
          #
          # @example Parse from array.
          #   cookies = [
          #     'aaa=111',
          #     'bbb=222'
          #   ]
          #   parse_from_response cookies
          #   # => {'aaa' => 111, 'bbb' => 222}
          #
          # @example Parse with `cookie_hash`.
          #   cookie_hash = {'ccc' => 333}
          #   parse_from_request 'aaa=111; bbb=222', cookie_hash
          #   cookie_hash
          #   # => {'aaa' => 1, 'bbb' => 2, 'ccc' => 333}
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

          # Parse response cookies on different formats.
          #
          # @param [String,Hash,Array] cookies Cookies to parse.
          # @param [Hash] cookie_hash ({}) External hash to store parsed cookies.
          #
          # @return [Hash]
          #
          # @example Parse from string
          #   parse_from_response 'aaa=111; bbb=222'
          #   # => {'aaa' => 111, 'bbb' => 222}
          #
          # @example Parse from array.
          #   cookies = [
          #     'aaa=111; Expires=Thu, Jan 01 1970 00:00:00 UTC; path=/',
          #     'bbb=222; path=/',
          #     'ccc=333; path=/; expires=Wed, Jan 01 3000 00:00:00 UTC'
          #   ]
          #   parse_from_response cookies
          #   # => {'bbb' => 222, 'ccc' => 333}
          #
          # @example Parse with `cookie_hash`.
          #   cookie_hash = {'ccc' => 333}
          #   parse_from_response 'aaa=111; bbb=222', cookie_hash
          #   cookie_hash
          #   # => {'aaa' => 111, 'bbb' => 222, 'ccc' => 333}
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

          # Apply request and response cookies as a hash.
          #
          # @param [String,Array,Hash] request_cookies Cookies to parse.
          # @param [String,Array,Hash] response_cookies Cookies to parse.
          #
          # @return [Hash]
          #
          # @example
          #   request_cookies = 'aaa=111; ddd=444'
          #   response_cookies = [
          #     'aaa=111; Expires=Thu, Jan 01 1970 00:00:00 UTC; path=/',
          #     'bbb=222; path=/',
          #     'ccc=333; path=/; expires=Wed, Jan 01 3000 00:00:00 UTC'
          #   ]
          #   update_as_hash , response_cookies
          #   # => {'bbb' => 222, 'ccc' => 333, 'ddd' => 444}
          def update_as_hash request_cookies, response_cookies
            cookie_hash = {}
            parse_from_request request_cookies, cookie_hash
            parse_from_response response_cookies, cookie_hash
            cookie_hash
          end

          # Encode cookies as request cookie string.
          #
          # @param [Hash] cookie_hash Hash with cookies.
          #
          # @return [String]
          #
          # @example
          #   cookie_hash = {
          #     'aaa' => 111,
          #     'bbb' => 222
          #   }
          #   encode_to_header cookie_hash
          #   # => 'aaa=111; bbb=222'
          def encode_to_header cookie_hash
            cookie_hash.map{|k,v| "#{k}=#{v}"}.join '; '
          end

          # Apply request and response cookies as a string with request format.
          #
          # @param [String,Array,Hash] request_cookies Cookies to parse.
          # @param [String,Array,Hash] response_cookies Cookies to parse.
          #
          # @return [String]
          #
          # @example
          #   request_cookies = 'aaa=111; ddd=444'
          #   response_cookies = [
          #     'aaa=111; Expires=Thu, Jan 01 1970 00:00:00 UTC; path=/',
          #     'bbb=222; path=/',
          #     'ccc=333; path=/; expires=Wed, Jan 01 3000 00:00:00 UTC'
          #   ]
          #   update_as_hash , response_cookies
          #   # => 'bbb=222; ccc=333; ddd=444'
          def update request_cookies, response_cookies
            cookie_hash = update_as_hash request_cookies, response_cookies
            encode_to_header cookie_hash
          end

          # Compare if cookie is included into base cookie
          #
          # @param [Hash] base_cookie_hash Hash that represent universe.
          # @param [Hash] cookie_hash Hash that represents to compare.
          #
          # @return [Boolean]
          #
          # @example Check a success match.
          #   base_cookie_hash = {
          #     'aaa' => 111,
          #     'bbb' => 222,
          #     'ccc' => 333,
          #     'ddd' => 444
          #   }
          #   cookie_hash = {
          #     'bbb' => 222,
          #     'ddd' => 444
          #   }
          #   include? base_cookie_hash, cookie_hash
          #   # => true
          #
          # @example Check with fail match.
          #   base_cookie_hash = {
          #     'aaa' => 111,
          #     'bbb' => 222,
          #     'ccc' => 333,
          #     'ddd' => 444
          #   }
          #   cookie_hash = {
          #     'bbb' => 555,
          #     'ddd' => 444
          #   }
          #   include? base_cookie_hash, cookie_hash
          #   # => false
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
