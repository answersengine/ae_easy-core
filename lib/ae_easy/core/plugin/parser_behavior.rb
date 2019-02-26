module AeEasy
  module Core
    module Plugin
      module ParserBehavior
        include AeEasy::Core::Plugin::ExecutorBehavior

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
