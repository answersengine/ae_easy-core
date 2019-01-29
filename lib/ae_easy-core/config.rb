module AeEasy
  module Core
    class Config
      include AeEasy::Core::Plugin::InitializeHook
      include AeEasy::Core::Plugin::ConfigBehavior

      alias :collection :config_collection

      def initialize_hook_config opts
        @config_collection = collection unless opts[:collection].nil?
      end

      def initialize opts = {}
        initialize_hooks opts
      end
    end
  end
end
