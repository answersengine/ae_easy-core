module AeEasy
  module Core
    module Plugin
      module Seeder
        include AeEasy::Core::Plugin::InitializeHook
        include AeEasy::Core::Plugin::SeederBehavior

        # Root input directory path.
        # @return [String]
        attr_accessor :root_input_dir

        # Referer to use on page seeding.
        # @return [String]
        attr_accessor :referer

        # Cookie to use on page seeing.
        # @return [String]
        attr_accessor :cookie

        # Hook to initialize seeder object.
        #
        # @param [Hash] opts ({}) Configuration options.
        # @option opts [String] :root_input_dir (nil) Root directory for inputs.
        # @option opts [String] :referer (nil) New pages referer, useful to dynamic setups.
        # @option opts [String] :cookie (nil) Cookie to use on seeded pages fetchs.
        def initialize_hook_core_seeder opts = {}
          @root_input_dir = opts[:root_input_dir]
          @referer = opts[:referer]
          @cookie = opts[:cookie]
        end

        # Initialize seeder and hooks.
        #
        # @param [Hash] opts ({}) Configuration options.
        #
        # @see AeEasy::Core::Plugin::ContextIntegrator#initialize_hook_core_context_integrator
        # @see #initialize_hook_core_seeder
        def initialize opts = {}
          initialize_hooks opts
        end
      end
    end
  end
end
