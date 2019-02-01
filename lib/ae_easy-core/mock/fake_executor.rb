module AeEasy
  module Core
    module Mock
      # Fake exector that emulates `AnswersEngine` executor.
      class FakeExecutor
        # Page content as string.
        attr_accessor :content
        # Failed page content as string.
        attr_accessor :failed_content
        # Draft pages, usually get saved after execution.
        attr_reader :pages
        # Draft outputs, usually get saved after execution.
        attr_reader:outputs

        include AnswersEngine::Plugin::ContextExposer

        # Remove all elements on pages.
        # @private
        def clear_draft_pages
          @pages ||= []
          @pages.clear
        end

        # Remove all elements on outputs.
        # @private
        def clear_draft_outputs
          @outputs ||= []
          @outputs.clear
        end

        # Fake database to represent what it is saved.
        def db
          @db ||= AeEasy::Core::Mock::FakeDb.new
        end

        # Initialize object.
        #
        # @param [Hash] opts ({}) Options
        # @option opts [Array] :pages (nil) Array to initialize pages, can be nil for empty.
        # @option opts [Array] :outputs (nil) Array to initialize outputs, can be nil for empty.
        # @option opts [Integer] :job_id (nil) A number to represent the job_id.
        def initialize opts = {}
          job_id = opts[:job_id]
          clear_draft_pages
          clear_draft_outputs
        end

        # Fake job ID used by executor.
        # @return [Integer,nil]
        def job_id
          db.job_id
        end

        # Set fake job id value.
        def job_id= value
          db.job_id = value
        end

        # Current page used by executor.
        # @return [Hash,nil]
        def page
          @page ||= AeEasy::Core::Mock::FakeDb.build_fake_page job_id: job_id
        end

        # Set current page.
        def page= value
          job_id = value['job_id']
          value['job_id'] ||= job_id
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

        # Save a page collection on db.
        #
        # @param [Array] list Collection of pages to save.
        def save_pages list
          list.each{|page| db.pages << page}
        end

        # Save an output collection on db.
        #
        # @param [Array] list Collection of outputs to save.
        def save_outputs list
          list.each{|output| db.outputs << output}
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
        def find_outputs collection = 'default', raw_query = {}, page = 1, per_page = 30
          count = 0
          offset = (page - 1) * per_page
          query = raw_query.merge(
            '_collection' => collection
          )
          db.query :outputs, query, offset, per_page
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
