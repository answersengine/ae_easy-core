module AeEasy
  module Core
    module Mock
      # Fake in memory database that emulates `Answersengine` database objects' black box behavior.
      class FakeDb
        # Page id keys, analog to primary keys.
        PAGE_KEYS = ['gid'].freeze
        # Output id keys, analog to primary keys.
        OUTPUT_KEYS = ['_id', '_collection'].freeze
        # Job id keys, analog to primary keys.
        JOB_KEYS = ['job_id'].freeze
        # Job available status.
        JOB_STATUSES = {
          active: 'active',
          done: 'done',
          cancelled: 'cancelled',
          paused: 'paused'
        }
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
          opts = {
            allow_page_gid_override: true,
            allow_job_id_override: true
          }.merge opts
          temp_db = AeEasy::Core::Mock::FakeDb.new opts
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

        # Clean an URL to remove fragment, lowercase schema and host, and sort
        #   query string.
        #
        # @param [String] raw_url URL to clean.
        #
        # @return [String]
        def self.clean_uri raw_url
          url = URI.parse(raw_url)
          url.hostname = url.hostname.downcase
          url.fragment = nil

          # Sort query string keys
          unless url.query.nil?
            query_string = CGI.parse(url.query)
            keys = query_string.keys.sort
            data = []
            keys.each do |key|
              query_string[key].each do |value|
                data << "#{URI.encode key}=#{URI.encode value}"
              end
            end
            url.query = data.join('&')
          end
          url.to_s
        end

        # Format headers for gid generation.
        # @private
        #
        # @param [Hash,nil] headers Headers hash.
        #
        # @return [Hash]
        def self.format_headers headers
          return {} if headers.nil?
          data = {}
          headers.each do |key, value|
            unless value.is_a? Array
              data[key] = value
              next
            end
            data[key] = value.sort
          end
          data
        end

        # Build a job with defaults by using FakeDb engine.
        #
        # @param [Hash] job Job initial values.
        # @param [Hash] opts ({}) Configuration options (see #initialize).
        #
        # @return [Hash]
        def self.build_job job, opts = {}
          temp_db = AeEasy::Core::Mock::FakeDb.new opts
          temp_db.jobs << job
          temp_db.jobs.last
        end

        # Build a fake job by using FakeDb engine.
        #
        # @param [Hash] opts ({}) Configuration options (see #initialize).
        # @option opts [String] :scraper_name (nil) Scraper name.
        # @option opts [Integer] :job_id (nil) Job id.
        # @option opts [String] :status ('done').
        #
        # @return [Hash]
        def self.build_fake_job opts = {}
          job = {
            'job_id' => opts[:job_id],
            'scraper_name' => opts[:scraper_name],
            'status' => (opts[:status] || 'done')
          }
          build_job job, opts
        end

        # Get current job or create new one from values.
        #
        # @param [Integer] target_job_id (nil) Job id to ensure existance.
        #
        # @return [Hash]
        def ensure_job target_job_id = nil
          target_job_id = job_id if target_job_id.nil?
          job = jobs.find{|v|v['job_id'] == target_job_id}
          return job unless job.nil?
          job = {
            'job_id' => target_job_id,
            'scraper_name' => scraper_name,
          }
          job['status'] = 'active' unless target_job_id != job_id
          jobs << job
          jobs.last
        end

        # Fake scraper_name.
        # @return [String,nil]
        def scraper_name
          @scraper_name ||= 'my_scraper'
        end

        # Set fake scraper_name value.
        def scraper_name= value
          job = ensure_job
          @scraper_name = value
          job['scraper_name'] = scraper_name
        end

        # Fake job id.
        # @return [Integer,nil]
        def job_id
          @job_id ||= generate_job_id
        end

        # Set fake job id value.
        def job_id= value
          @job_id = value
          ensure_job
          job_id
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

        # Enable page gid override on page or output insert.
        def enable_page_gid_override
          @allow_page_gid_override = true
        end

        # Disable page gid override on page or output insert.
        def disable_page_gid_override
          @allow_page_gid_override = false
        end

        # Specify whenever page gid overriding by user is allowed on page or
        #   output insert.
        #
        # @return [Boolean] `true` when allowed, else `false`.
        def allow_page_gid_override?
          @allow_page_gid_override ||= false
        end

        # Enable job id override on page or output insert.
        def enable_job_id_override
          @allow_job_id_override = true
        end

        # Disable job id override on page or output insert.
        def disable_job_id_override
          @allow_job_id_override = false
        end

        # Specify whenever job id overriding by user is allowed on page or
        #   output insert.
        #
        # @return [Boolean] `true` when allowed, else `false`.
        def allow_job_id_override?
          @allow_job_id_override ||= false
        end

        # Initialize fake database.
        #
        # @param [Hash] opts ({}) Configuration options.
        # @option opts [Integer,nil] :job_id Job id default value.
        # @option opts [String,nil] :scraper_name Scraper name default value.
        # @option opts [String,nil] :page_gid Page gid default value.
        # @option opts [Boolean, nil] :allow_page_gid_override (false) Specify
        #   whenever page gid can be overrided on page or output insert.
        # @option opts [Boolean, nil] :allow_job_id_override (false) Specify
        #   whenever job id can be overrided on page or output insert.
        def initialize opts = {}
          self.job_id = opts[:job_id]
          self.scraper_name = opts[:scraper_name]
          self.page_gid = opts[:page_gid]
          @allow_page_gid_override = opts[:allow_page_gid_override].nil? ? false : !!opts[:allow_page_gid_override]
          @allow_job_id_override = opts[:allow_job_id_override].nil? ? false : !!opts[:allow_job_id_override]
        end

        # Generate a fake scraper name.
        #
        # @return [String]
        def generate_scraper_name
          Faker::Internet.unique.slug
        end

        # Generate a fake job_id.
        #
        # @return [Integer]
        def generate_job_id
          jobs.count < 1 ? 1 : (jobs.max{|a,b|a['job_id'] <=> b['job_id']}['job_id'] + 1)
        end

        # Get output keys with key generators to emulate saving on db.
        # @private
        #
        # @return [Hash]
        def job_defaults
          @job_defaults ||= {
            'job_id' => lambda{|job| generate_job_id},
            'scraper_name' => lambda{|job| generate_scraper_name},
            'status' => 'done',
            'created_at' => lambda{|job| Time.now}
          }
        end

        # Stored job collection
        #
        # @return [AeEasy::Core::SmartCollection]
        def jobs
          return @jobs unless @jobs.nil?
          collection = self.class.new_collection JOB_KEYS,
            defaults: job_defaults
          collection.bind_event(:before_defaults) do |collection, raw_item|
            AeEasy::Core.deep_stringify_keys raw_item
          end
          collection.bind_event(:before_insert) do |collection, item, match|
            item['job_id'] ||= generate_job_id
            item
          end
          @jobs ||= collection
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
        # @param [Hash] page_data Page data.
        #
        # @return [String]
        def generate_page_gid page_data
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
          data = page_data.select{|k,v|fields.include? k}
          data['url'] = self.class.clean_uri data['url']
          data['headers'] = self.class.format_headers data['headers']
          data['cookie'] = AeEasy::Core::Helper::Cookie.parse_from_request data['cookie'] unless data['cookie'].nil?
          seed = data.select{|k,v|fields.include? k}.hash
          checksum = self.class.fake_uuid seed
          "#{URI.parse(data['url']).hostname}-#{checksum}"
        end

        # Get page keys with key generators to emulate saving on db.
        # @private
        #
        # @return [Hash]
        def page_defaults
          @page_defaults ||= {
            'url' => nil,
            'job_id' => lambda{|page| job_id},
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
            item = AeEasy::Core.deep_stringify_keys raw_item
            item.delete 'job_id' unless allow_job_id_override?
            item
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
          @output_defaults ||= {
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
            item = AeEasy::Core.deep_stringify_keys raw_item
            item.delete '_job_id' unless allow_job_id_override?
            item.delete '_gid_id' unless allow_page_gid_override?
            item
          end
          collection.bind_event(:before_insert) do |collection, item, match|
            item['_id'] ||= generate_output_id item
            item
          end
          collection.bind_event(:after_insert) do |collection, item|
            ensure item['job_id']
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
        # @param [Integer,nil] limit (nil) Limit search results count. Set to `nil` for unlimited.
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
          when :jobs
            jobs
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
