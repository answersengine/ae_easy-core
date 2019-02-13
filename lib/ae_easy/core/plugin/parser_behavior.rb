module AeEasy
  module Core
    module Plugin
      module ParserBehavior
        include AeEasy::Core::Plugin::ContextIntegrator

        # Enqueue a single/multiple pages for fetch. Analog to `save_pages`.
        #
        # @param [Array,Hash] pages Pages to save being Hash when single and Array when many.
        #
        # @note Instance must implement:
        #   * `save_pages(pages)`
        def enqueue pages
          pages = [pages] unless pages.is_a? Array
          save_pages pages
        end

        # Save a single/multiple outputs. Analog to `save_outputs`.
        #
        # @param [Array,Hash] outputs Outputs to save being Hash when single and Array when many.
        #
        # @note Instance must implement:
        #   * `save_outputs(outputs)`
        def save outputs
          outputs = [outputs] unless outputs.is_a? Array
          save_outputs outputs
        end

        # Alias to `page['vars']`.
        #
        # @note Instance must implement:
        #   * `page`
        def vars
          page['vars']
        end
      end
    end
  end
end
