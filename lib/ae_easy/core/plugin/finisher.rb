module AeEasy
  module Core
    module Plugin
      module Finisher
        include AeEasy::Core::Plugin::InitializeHook
        include AeEasy::Core::Plugin::FinisherBehavior

        # Initialize finisher and hooks.
        #
        # @param [Hash] opts ({}) Configuration options.
        #
        # @see AeEasy::Core::Plugin::ContextIntegrator#initialize_hook_core_context_integrator
        def initialize opts = {}
          initialize_hooks opts
        end
      end
    end
  end
end
