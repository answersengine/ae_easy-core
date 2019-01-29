module AeEasy
  module Core
    module Plugin
      module ContextIntegrator
        attr_reader :context

        def mock_context source
          @context = source
          AeEasy::Core.mock_instance_methods context, self
        end

        def initialize_hook_context_integrator opts
          raise ':context object is required.' if opts[:context].nil?
          mock_context opts[:context]
        end
      end
    end
  end
end
