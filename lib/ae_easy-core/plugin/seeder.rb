module AeEasy
  module Core
    module Plugin
      module Seeder
        attr_reader :root_input_dir, :referer, :cookie

        include AeEasy::Core::Plugin::InitializeHook
        include AeEasy::Core::Plugin::SeederBehavior

        def initialize_hook_seeder opts
          @root_input_dir = opts[:root_input_dir]
          @referer = opts[:referer]
          @cookie = opts[:cookie]
        end

        def initialize opts = {}
          initialize_hooks opts
        end
      end
    end
  end
end
