module AeEasy
  module Core
    module Mock
      # Fake executor that emulates `AnswersEngine` executor.
      module FakeExecutor
        # Page content.
        # @return [String,nil]
        attr_accessor :content
        # Failed page content.
        # @return [String,nil]
        attr_accessor :failed_content

        include AnswersEngine::Plugin::ContextExposer

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
          self.page = opts[:page]
        end

        # Fake job ID used by executor.
        # @return [Integer,nil]
        def job_id
          db.job_id
        end

        # Set fake job id value.
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

        # Retrive a list of saved pages. Drafted pages can be included.
        def saved_pages
          db.pages
        end

        # Retrive a list of saved outputs.
        def saved_outputs
          db.outputs
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
          fixed_query = query.merge(
            '_collection' => collection
          )
          db.query :outputs, fixed_query, offset, per_page
        end

        # Find one output by collection and query with pagination.
        #
        # @param [String] collection ('default') Collection name.
        # @param [Hash] query ({}) Filters to query.
        #
        # @return [Hash, nil]
        def find_output collection = 'default', query = {}
          result = find_outputs(collection, query, 1, 1)
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
