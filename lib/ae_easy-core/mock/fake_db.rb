module AeEasy
  module Core
    module Mock
      # Fake in memory database that emulates `Answersengine` database objects' black box behavior.
      class FakeDb
        # Page id keys, analog to primary keys.
        PAGE_KEYS = ['gid'].freeze
        # Output id keys, analog to primary keys.
        OUTPUT_KEYS = ['_id', '_collection'].freeze
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

        # Build a page with defaults by using FakeDb engine.
        #
        # @param [Hash] page Page initial values.
        # @param [Hash] opts ({}) Configuration options (see #initialize).
        #
        # @return [Hash]
        def self.build_page page, opts = {}
          temp_db = AeEasy::Core::Mock::FakeDb.new opts
          temp_db.enable_page_gid_override
          temp_db.pages << page
          temp_db.pages.first
        end

        # Build a fake page by using FakeDb engine.
        #
        # @param [Hash] opts ({}) Configuration options (see #initialize).
        # @option opts [String] :url ('https://example.com') Page url.
        #
        # @return [Hash]
        def self.build_fake_page opts = {}
          page = {
            'url' => (opts[:url] || 'https://example.com')
          }
          build_page page, opts
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

        # Enable page gid override on page insert.
        def enable_page_gid_override
          @allow_page_gid_override = true
        end

        # Disable page gid override on page insert.
        def disable_page_gid_override
          @allow_page_gid_override = false
        end

        # Specify whenever page gid overriding by user is allowed on page
        #   insert.
        #
        # @return [Boolean] `true` when allowed, else `false`.
        def allow_page_gid_override?
          @allow_page_gid_override ||= false
        end

        # Initialize fake database.
        #
        # @param [Hash] opts ({}) Configuration options.
        # @option opts [Integer,nil] :job_id Job id default value.
        # @option opts [String,nil] :page_gid Page gid default value.
        # @option opts [Boolean, nil] :allow_page_gid_override (false) Specify
        #   whenever page gid can be overrided on page insert.
        def initialize opts = {}
          self.job_id = opts[:job_id]
          self.page_gid = opts[:page_gid]
          @allow_page_gid_override = opts[:allow_page_gid_override].nil? ? false : !!opts[:allow_page_gid_override]
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
            'ua_type' => 'desktop',
            'vars' => {}
          }
        end

        # Stored page collection.
        #
        # @return [AeEasy::Core::SmartCollection]
        #
        # @note Page gid will be replaced on insert by an auto generated uuid
        #   unless page gid overriding is enabled
        #   (see #allow_page_gid_override?)
        def pages
          return @pages unless @page.nil?

          collection = self.class.new_collection PAGE_KEYS,
            defaults: page_defaults
          collection.bind_event(:before_defaults) do |collection, raw_item|
            AeEasy::Core.deep_stringify_keys raw_item
          end
          collection.bind_event(:before_insert) do |collection, item, match|
            if item['gid'].nil? || !allow_page_gid_override?
              item['gid'] = generate_page_gid item
            end
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
            '_collection' => DEFAULT_COLLECTION,
            '_job_id' => lambda{|output| job_id},
            '_created_at' => lambda{|output| Time.new.strftime('%Y-%m-%dT%H:%M:%SZ')},
            '_gid' => lambda{|output| page_gid}
          }
        end

        # Stored output collection
        #
        # @return [AeEasy::Core::SmartCollection]
        def outputs
          return @outputs unless @outputs.nil?
          collection = self.class.new_collection OUTPUT_KEYS,
            defaults: output_defaults
          collection.bind_event(:before_defaults) do |collection, raw_item|
            AeEasy::Core.deep_stringify_keys raw_item
          end
          collection.bind_event(:before_insert) do |collection, item, match|
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
        #
        # @note Missing and `nil` values on `data` will match when `filters`'
        #   field is `nil`.
        def match? data, filters
          filters.each do |key, value|
            return false if data[key] != value
          end
          true
        end

        # Search items from a collection.
        #
        # @param [Symbol] collection Allowed values: `:outputs`, `:pages`.
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
            next unless match? item, filter
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
