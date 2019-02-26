module AeEasy
  module Core
    # Configuration manager tool useful for global configuration data accross
    #   the scraping process.
    class Config
      include AeEasy::Core::Plugin::InitializeHook
      include AeEasy::Core::Plugin::ConfigBehavior

      # {AeEasy::Core::Plugin::ConfigBehavior#config_collection_key}
      alias :collection_key :config_collection_key
      # {AeEasy::Core::Plugin::ConfigBehavior#config_collection}
      alias :collection :config_collection

      # Initialize config object
      #
      # @param [Hash] opts ({}) Configuration options.
      #
      # @see AeEasy::Core::Plugin::ConfigBehavior#initialize_hook_core_config_behavior
      def initialize opts = {}
        opts = opts.merge(
          config_collection: opts[:collection]
        )
        initialize_hooks opts
      end
    end
  end
end
