module AeEasy
  module Core
    module Mock
      class FakeExecutor
        # Page id keys, analog to primary keys.
        PAGE_KEYS = ['_id', '_collection'].freeze
        # Output id keys, analog to primary keys.
        OUTPUT_KEYS = ['_gid'].freeze
        # Default collection for saved outputs
        DEFAULT_COLLECTION = 'default'

        # Page content as string.
        attr_accessor :content
        # Failed page content as string.
        attr_accessor :failed_content
        # Fake database to represent what it is saved.
        attr_reader :db
        # Draft pages, usually get saved after execution.
        attr_reader :pages
        # Draft outputs, usually get saved after execution.
        attr_reader:outputs

        include AnswersEngine::Plugin::ContextExposer

        # Generate a fake UUID.
        def self.fake_uuid
          seed = (Time.new.to_f + rand)
          Digest::SHA1.hexdigest seed.to_s
        end

        # Generate a smart collection with keys and initial values.
        #
        # @param [Array] keys Analog to primary keys, combination will be uniq.
        # @param [Array,nil] values (nil) Collection initial array.
        #
        # @return [AeEasy::Core::SmartCollection]
        def self.new_collection keys, values = nil
          AeEasy::Core::SmartCollection.new keys, values
        end

        # Remove all elements on pages.
        # @private
        def clear_draft_pages
          @pages = self.class.new_collection PAGE_KEYS
        end

        # Remove all elements on outputs.
        # @private
        def clear_draft_outputs
          @outputs = self.class.new_collection OUTPUT_KEYS
        end

        # Get page keys with key generators to emulate saving on db.
        # @private
        #
        # @return [Hash]
        def db_page_keys
          @db_page_keys ||= Hash[PAGE_KEYS.map{|k|[k, nil]}].merge(
            'gid' => lambda{self.class.fake_uuid}
          )
        end

        # Get output keys with key generators to emulate saving on db.
        # @private
        #
        # @return [Hash]
        def db_output_keys
          @db_output_keys ||= Hash[PAGE_KEYS.map{|k|[k, nil]}].merge(
            '_id': lambda{self.class.fake_uuid},
            '_collection': DEFAULT_COLLECTION,
            '_job_id': lambda{job_id},
            '_created_at': lambda{Time.new.strftime('%Y-%m-%dT%H:%M:%SZ')},
            '_gid': lambda{page.nil? ? nil : page['gid']}
          )
        end

        # Initialize object.
        #
        # @param [Hash] opts ({}) Options
        # @option opts [Array] :pages (nil) Array to initialize pages, can be nil for empty.
        # @option opts [Array] :outputs (nil) Array to initialize outputs, can be nil for empty.
        # @option opts [Integer] :job_id (nil) A number to represent the job_id.
        def initialize opts = {}
          @db = {
            pages: self.class.new_collection(db_page_keys, opts[:pages]),
            outputs: self.class.new_collection(db_output_keys, opts[:outputs])
          }
          job_id = opts[:job_id]
          clear_draft_pages
          clear_draft_outputs
        end

        # Fake job ID used by executor.
        # @return [Integer,nil]
        def job_id
          @job_id ||= rand(1000) + 1
        end

        # Set fake job id value.
        def job_id= value
          @job_id = value
        end

        # Current page used by executor.
        # @return [Hash,nil]
        def page
          @page
        end

        # Set current page.
        def page= value
          job_id = page['job_id']
          page['job_id'] = job_id if page['job_id'].nil?
          @page = page
        end

        # Retrive a list of saved pages. Drafted pages can be included.
        #
        # @param [Hash] opts ({}) Save options.
        # @option opts [Boolean] :include_draft (true) Specify if draft pages should be included.
        def saved_pages opts = {}
          opts = {
            include_draft: true
          }.merge opts
          list = self.class.new_collection PAGE_KEYS
          db[:pages].each{|item|list << item}
          pages.each{|item|list << item} if opts[:include_draft]
          list
        end

        # Retrive a list of saved outputs. Drafted outputs can be included.
        #
        # @param [Hash] opts ({}) Save options.
        # @option opts [Boolean] :include_draft (true) Include draft outputs when true.
        def saved_outptus opts = {}
          opts = {
            include_draft: true
          }.merge opts
          list = self.class.new_collection OUTPUT_KEYS
          db[:outputs].each{|item|list << item}
          outputs.each{|item|list << item} if opts[:include_draft]
          list
        end

        # Save a page collection on db.
        #
        # @param [Array] list Collection of pages to save.
        def save_pages list
          list.each{|page| db[:pages] << page}
        end

        # Save an output collection on db.
        #
        # @param [Array] list Collection of outputs to save.
        def save_outputs list
          list.each do |output|
            db[:outputs] << {
              '_gid': page.nil? ? nil : page['_gid'],
              '_id': self.class.fake_uuid,
              '_job_id': page.nil? ? nil : page['job_id'],
            }.merge(output)
          end
        end

        # Save draft pages into db and clear draft queue.
        def flush_pages
          save_pages pages
          clear_draft_pages
        end

        # Save draft outputs into db and clear draft queue.
        def flush_outputs
          save_outputs outputs
          clear_draft_outputs
        end

        # Save all drafts into db and clear draft queues.
        def flush
          flush_pages
          flush_outputs
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

        # Find outputs by collection and query with pagination.
        #
        # @param [String] collection ('default') Collection name.
        # @param [Hash] query ({}) Filters to query.
        # @param [Integer] page (1) Page number.
        # @param [Integer] per_page (30) Page size.
        #
        # @return [Array]
        def find_outputs collection = 'default', query = {}, page = 1, per_page = 30
          count = 0
          offset = (page - 1) * per_page
          matches = []
          db[:outputs].each do |output|
            next unless match? output, filter

            # Reach page
            count += 1
            next unless offset < count

            # Break when page size reach
            break unless matches.count < per_page
            matches << output
          end
          matches
        end

        # Find one output by collection and query with pagination.
        #
        # @param [String] collection ('default') Collection name.
        # @param [Hash] query ({}) Filters to query.
        #
        # @return [Hash, nil]
        def find_output collection = 'default', query = {}
          fint_outputs collection, query, 1, 1
        end

        # Validate executor methods compatibility.
        # @private
        #
        # @param [Array] source Answersengine executor method collection.
        # @param [Array] fragment Fake executor method collection.
        #
        # @return [Hash]
        # @raise [AeEasy::Core::Exception::OutdatedError] When missing methods.
        def check_compatibility source, fragment
          report = AeEasy::Core.analyze_compatibility source, fragment

          unless report[:new].count < 1
            # Warn when outdated
            warn <<-LONGDESC.gsub(/^\s+/,'')
              It seems answersengine has new unmapped methods, try updating
              ae_easy-core gem or contacting gem maintainer to update it.
              New methods: #{report[:new].join ', '}
            LONGDESC
          end

          # Ensure no missing methods
          unless report[:is_compatible]
            message = <<-LONGDESC.gsub(/^\s+/,'')
              There are missing methods! Check your answersengine gem version.
              Missing methods: #{report[:missing].join ', '}
            LONGDESC
            raise AeEasy::Core::Exception::OutdatedError.new(message)
          end

          report
        end

        # Execute an script file as an executor.
        #
        # @param [String] file_path Script file path to execute.
        def execute_script file_path
          eval(File.read(file_path), isolated_binding, file_path)
          flush
        end
      end
    end
  end
end
