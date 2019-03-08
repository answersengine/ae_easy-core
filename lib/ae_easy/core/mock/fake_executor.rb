module AeEasy
  module Core
    module Mock
      # Fake executor that emulates `AnswersEngine` executor.
      module FakeExecutor
        include AnswersEngine::Plugin::ContextExposer

        # Max allowed page size when query outputs (see #find_outputs).
        MAX_FIND_OUTPUTS_PER_PAGE = 500

        # Page content.
        # @return [String,nil]
        attr_accessor :content
        # Failed page content.
        # @return [String,nil]
        attr_accessor :failed_content

        # Validate executor methods compatibility.
        # @private
        #
        # @param [Array] source Answersengine executor method collection.
        # @param [Array] fragment Fake executor method collection.
        #
        # @return [Hash]
        # @raise [AeEasy::Core::Exception::OutdatedError] When missing methods.
        def self.check_compatibility source, fragment
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

        # Draft pages, usually get saved after execution.
        # @return [Array]
        def pages
          @pages ||= []
        end

        # Draft outputs, usually get saved after execution.
        # @return [Array]
        def outputs
          @outputs ||= []
        end

        # Remove all elements on pages.
        # @private
        def clear_draft_pages
          @pages.clear
        end

        # Remove all elements on outputs.
        # @private
        def clear_draft_outputs
          @outputs.clear
        end

        # Fake database to represent what it is saved.
        def db
          @db ||= AeEasy::Core::Mock::FakeDb.new
        end

        # Initialize object.
        #
        # @param [Hash] opts ({}) Configuration options.
        # @option opts [Array] :pages (nil) Array to initialize pages, can be nil for empty.
        # @option opts [Array] :outputs (nil) Array to initialize outputs, can be nil for empty.
        # @option opts [Integer] :job_id (nil) A number to represent the job_id.
        # @option opts [Hash] :page (nil) Current page.
        #
        # @raise [ArgumentError] When pages or outputs are not Array.
        def initialize opts = {}
          unless opts[:pages].nil? || opts[:pages].is_a?(Array)
            raise ArgumentError.new "Pages must be an array."
          end
          @pages = opts[:pages]
          unless opts[:outputs].nil? || opts[:outputs].is_a?(Array)
            raise ArgumentError.new "Outputs must be an array."
          end
          @outputs = opts[:outputs]
          self.job_id = opts[:job_id]
          self.scraper_name = opts[:scraper_name]
          self.page = opts[:page]
        end

        # Fake scraper name used by executor.
        # @return [Integer,nil]
        def scraper_name
          db.scraper_name
        end

        # Set fake scraper name value.
        def scraper_name= value
          db.scraper_name = value
        end

        # Fake job ID used by executor.
        # @return [Integer,nil]
        def job_id
          db.job_id
        end

        # Set fake job ID value.
        def job_id= value
          db.job_id = value
          page['job_id'] = value
        end

        # Current page used by executor.
        # @return [Hash,nil]
        def page
          @page ||= AeEasy::Core::Mock::FakeDb.build_fake_page job_id: job_id
        end

        # Set current page.
        def page= value
          unless value.nil?
            value = AeEasy::Core::Mock::FakeDb.build_page value
            self.job_id = value['job_id'] unless value['job_id'].nil?
            value['job_id'] ||= job_id
            db.page_gid = value['gid'] unless value['gid'].nil?
          end
          @page = value
        end

        # Retrive a list of saved jobs.
        def saved_jobs
          db.jobs
        end

        # Retrive a list of saved pages. Drafted pages can be included.
        def saved_pages
          db.pages
        end

        # Retrive a list of saved outputs.
        def saved_outputs
          db.outputs
        end

        # Save a job collection on db and remove all the element from +list+.
        #
        # @param [Array] list Collection of jobs to save.
        def save_jobs list
          list.each{|job| db.jobs << job}
          list.clear
        end

        # Save a page collection on db and remove all the element from +list+.
        #
        # @param [Array] list Collection of pages to save.
        def save_pages list
          list.each{|page| db.pages << page}
          list.clear
        end

        # Save an output collection on db and remove all the element from
        #   +list+.
        #
        # @param [Array] list Collection of outputs to save.
        def save_outputs list
          list.each{|output| db.outputs << output}
          list.clear
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

        # Get latest job by scraper_name.
        #
        # @param [String] scraper_name Scraper name.
        # @param [Hash] filter ({}) Additional_filters.
        #
        # @return [Hash,nil] Return nil if no scraper_name or scraper_name is
        #   nil.
        def latest_job_by scraper_name, filter = {}
          return nil if scraper_name.nil?
          data = db.query :jobs, filter.merge('scraper_name' => scraper_name)
          data.max{|a,b| a['created_at'] <=> b['created_at']}
        end

        # Find outputs by collection and query with pagination.
        #
        # @param [String] collection ('default') Collection name.
        # @param [Hash] query ({}) Filters to query.
        # @param [Integer] page (1) Page number.
        # @param [Integer] per_page (30) Page size.
        # @param [Hash] opts ({}) Configuration options.
        # @option opts [String,nil] :scraper_name (nil) Scraper name to query
        #   from.
        # @option opts [Integer,nil] :job_id (nil) Job's id to query from.
        #
        # @raise [ArgumentError] +collection+ is not String.
        # @raise [ArgumentError] +query+ is not a Hash.
        # @raise [ArgumentError] +page+ is not an Integer greater than 0.
        # @raise [ArgumentError] +per_page+ is not an Integer between 1 and 500.
        #
        # @return [Array]
        #
        # @example
        #   find_outputs
        # @example
        #   find_outputs 'my_collection'
        # @example
        #   find_outputs 'my_collection', {}
        # @example
        #   find_outputs 'my_collection', {}, 1
        # @example
        #   find_outputs 'my_collection', {}, 1, 30
        # @example Find from another scraper by name
        #   find_outputs 'my_collection', {}, 1, 30, scraper_name: 'my_scraper'
        # @example Find from another scraper by job_id
        #   find_outputs 'my_collection', {}, 1, 30, job_id: 123
        #
        # @note *opts `:job_id` option is prioritize over `:scraper_name` when
        #   both exists. If none add provided or nil values, then current job
        #   will be used to query instead, this is the defaul behavior.
        def find_outputs collection = 'default', query = {}, page = 1, per_page = 30, opts = {}
          raise ArgumentError.new("collection needs to be a String.") unless collection.is_a?(String)
          raise ArgumentError.new("query needs to be a Hash.") unless query.is_a?(Hash)
          unless page.is_a?(Integer) && page > 0
            raise ArgumentError.new("page needs to be an Integer greater than 0.")
          end
          unless per_page.is_a?(Integer) && per_page > 0 && per_page <= MAX_FIND_OUTPUTS_PER_PAGE
            raise ArgumentError.new("per_page needs to be an Integer between 1 and #{MAX_FIND_OUTPUTS_PER_PAGE}.")
          end

          count = 0
          offset = (page - 1) * per_page
          job = latest_job_by(opts[:scraper_name])
          fixed_query = query.merge(
            '_collection' => collection,
            '_job_id' => opts[:job_id] || (job.nil? ? job_id : job['job_id'])
          )
          db.query :outputs, fixed_query, offset, per_page
        end

        # Find one output by collection and query with pagination.
        #
        # @param [String] collection ('default') Collection name.
        # @param [Hash] query ({}) Filters to query.
        # @param [Hash] opts ({}) Configuration options.
        # @option opts [String,nil] :scraper_name (nil) Scraper name to query
        #   from.
        # @option opts [Integer,nil] :job_id (nil) Job's id to query from.
        #
        # @raise [ArgumentError] +collection+ is not String.
        # @raise [ArgumentError] +query+ is not a Hash.
        #
        # @return [Hash, nil]
        #
        # @example
        #   find_output
        # @example
        #   find_output 'my_collection'
        # @example
        #   find_output 'my_collection', {}
        # @example Find from another scraper by name
        #   find_output 'my_collection', {}, scraper_name: 'my_scraper'
        # @example Find from another scraper by job_id
        #   find_output 'my_collection', {}, job_id: 123
        #
        # @note *opts `:job_id` option is prioritize over `:scraper_name` when
        #   both exists. If none add provided or nil values, then current job
        #   will be used to query instead, this is the defaul behavior.
        def find_output collection = 'default', query = {}, opts = {}
          result = find_outputs(collection, query, 1, 1, opts)
          result.nil? ? nil : result.first
        end

        # Execute an script file as an executor.
        #
        # @param [String] file_path Script file path to execute.
        def execute_script file_path, vars = {}
          eval(File.read(file_path), isolated_binding(vars), file_path)
          flush
        end
      end
    end
  end
end
