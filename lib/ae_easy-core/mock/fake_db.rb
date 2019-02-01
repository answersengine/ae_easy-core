module AeEasy
  module Core
    module Mock
      # Fake in memory database that emulates `Answersengine` database objects black box behavior.
      class FakeDb
        # Page id keys, analog to primary keys.
        PAGE_KEYS = ['_id', '_collection'].freeze
        # Output id keys, analog to primary keys.
        OUTPUT_KEYS = ['_gid'].freeze
        # Default collection for saved outputs
        DEFAULT_COLLECTION = 'default'

        # Generate a smart collection with keys and initial values.
        #
        # @param [Array] keys Analog to primary keys, combination will be uniq.
        # @param [Hash] opts Configuration options (see AeEasy::Core::SmartCollection#initialize).
        #
        # @return [AeEasy::Core::SmartCollection]
        def self.new_collection keys, opts = {}
          AeEasy::Core::SmartCollection.new keys, opts
        end

        # Generate a fake UUID.
        #
        # @param seed (nil) Object to use as seed for uuid.
        #
        # @return [String]
        def self.fake_uuid seed = nil
          seed ||= (Time.new.to_f + rand)
          Digest::SHA1.hexdigest seed.to_s
        end

        # Build a fake page by using FakeDb engine.
        #
        # @param [Hash] opts ({}) Configuration options (see #initialize).
        # @option opts [String] :url ('https://example.com') Page url.
        #
        # @return [Hash]
        def self.build_fake_page opts = {}
          temp_db = AeEasy::Core::Mock::FakeDb.new opts
          temp_db.pages << {
            'url' => (opts[:url] || 'https://example.com')
          }
          temp_db.pages.first
        end

        # Fake job id.
        # @return [Integer,nil]
        def job_id
          @job_id ||= rand(1000) + 1
        end

        # Set fake job id value.
        def job_id= value
          @job_id = value
        end

        # Current fake page gid.
        # @return [Integer,nil]
        def page_gid
          @page_gid ||= self.class.fake_uuid
        end

        # Set current fake page gid value.
        def page_gid= value
          @page_gid = value
        end

        # Initialize fake database.
        #
        # @param [Hash] opts ({}) Configuration options.
        # @option opts [Integer,nil] :job_id Job id default value.
        # @option opts [Integer,nil] :page_gid Page gid default value.
        def initialize opts = {}
          job_id = opts[:job_id]
          page_gid = opts[:page_gid]
        end

        # Generate a fake UUID based on page data:
        #   * url
        #   * method
        #   * headers
        #   * fetch_type
        #   * cookie
        #   * no_redirect
        #   * body
        #   * ua_type
        #
        # @param [Hash] data Output data.
        #
        # @return [String]
        def generate_page_gid data
          fields = [
            'url',
            'method',
            'headers',
            'fetch_type',
            'cookie',
            'no_redirect',
            'body',
            'ua_type'
          ]
          seed = data.select{|k,v|fields.include? k}.hash
          self.class.fake_uuid seed
        end

        # Get page keys with key generators to emulate saving on db.
        # @private
        #
        # @return [Hash]
        def page_defaults
          @page_keys ||= {
            'url' => nil,
            'method' => 'GET',
            'headers' => {},
            'fetch_type' => 'standard',
            'cookie' => nil,
            'no_redirect' => false,
            'body' => nil,
            'ua_type' => 'desktop'
          }
        end

        # Stored page collection.
        #
        # @return [AeEasy::Core::SmartCollection]
        def pages
          return @pages unless @page.nil?

          collection = self.class.new_collection PAGE_KEYS,
            defaults: page_defaults
          collection.add_event(:before_defaults) do |collection, raw_item|
            AeEasy::Core.deep_stringify_keys raw_item
          end
          collection.add_event(:before_insert) do |collection, item|
            item['gid'] ||= generate_page_id item
            item
          end
          @pages ||= collection
        end

        # Generate a fake UUID based on output fields without `_` prefix.
        #
        # @param [Hash] data Output data.
        #
        # @return [String]
        def generate_output_id data
          seed = data.select{|k,v|k.to_s =~ /^[^_]/}.hash
          self.class.fake_uuid seed
        end

        # Get output keys with key generators to emulate saving on db.
        # @private
        #
        # @return [Hash]
        def output_defaults
          @output_keys ||= {
            '_collection': DEFAULT_COLLECTION,
            '_job_id': lambda{job_id},
            '_created_at': lambda{Time.new.strftime('%Y-%m-%dT%H:%M:%SZ')},
            '_gid': lambda{page_gid}
          }
        end

        # Stored output collection
        #
        # @return [AeEasy::Core::SmartCollection]
        def outputs
          return @outputs unless @outputs.nil?
          collection = self.class.new_collection OUTPUT_KEYS,
            defaults: output_defaults
          collection.add_event(:before_defaults) do |collection, raw_item|
            AeEasy::Core.deep_stringify_keys raw_item
          end
          collection.add_event(:before_insert) do |collection, item|
            item['_id'] ||= generate_output_id item
            item
          end
          @outputs ||= collection
        end

        # Match data to filters.
        # @private
        #
        # @param data Hash containing data.
        # @param filters Filters to apply on match.
        #
        # @return [Boolean]
        def match? data, filters
          filters.each do |key, value|
            return false if data[k] != v
          end
          true
        end

        # Search items from a collection.
        #
        # @param [Symbol] Allowed values: `:outputs`, `:pages`.
        # @param [Hash] filter Filters to query.
        # @param [Integer] offset (0) Search results offset.
        # @param [Integer|nil] limit (nil) Limit search results count. Set to `nil` for unlimited.
        #
        # @raise ArgumentError On unknown collection.
        #
        # @note _Warning:_ It uses table scan to filter and should be used on test suites only.
        def query collection, filter, offset = 0, limit = nil
          return [] unless limit.nil? || limit > 0

          # Get collection items
          items = case collection
          when :outputs
            outputs
          when :pages
            pages
          else
            raise ArgumentError.new "Unknown collection #{collection}."
          end

          # Search items
          count = 0
          matches = []
          items.each do |item|
            next unless match? output, filter
            count += 1

            # Skip until offset
            next unless offset < count
            # Break on limit reach
            break unless limit.nil? || matches.count < limit
            matches << item
          end
          matches
        end
      end
    end
  end
end
