module AeEasy
  module Core
    module Plugin
      module ExecutorBehavior
        include AeEasy::Core::Plugin::ContextIntegrator

        # Enqueue a single/multiple pages for fetch. Analog to `save_pages`.
        #
        # @param [Array,Hash] object Pages to save being Hash when single and
        #   Array when many.
        #
        # @note Instance must implement:
        #   * `save_pages(pages)`
        def enqueue object
          object = [object] unless object.is_a? Array
          save_pages object
        end

        # Save a single/multiple outputs. Analog to `save_outputs`.
        #
        # @param [Array,Hash] object Outputs to save being Hash when single and Array when many.
        #
        # @note Instance must implement:
        #   * `save_outputs(outputs)`
        def save object
          object = [object] unless object.is_a? Array
          save_outputs object
        end
      end
    end
  end
end
