module AeEasy
  module Core
    module Plugin
      module ConfigBehavior
        attr_reader :config_collection_key

        include AeEasy::Core::Plugin::ContextIntegrator
        include AeEasy::Core::Plugin::CollectionVault

        # Hook to map config behavior on self
        #
        # @param [Hash] opts ({}) Configuration options.
        # @option opts [Array] :config_collection ([:config, 'config']) Key value pair array to se a custom collection.
        #
        # @example
        #   initialize_hook_core_config_behavior config_collection: [:my_config, 'abc']
        #   config_collection
        #   # => 'abc'
        def initialize_hook_core_config_behavior opts = {}
          @config_collection_key, collection = opts[:config_collection] || [:config, 'config']
          add_collection config_collection_key, collection
        end

        # Get config collection name.
        # @return [String]
        def config_collection
          collections[config_collection_key]
        end

        # Find a configuration value by item key.
        #
        # @param [Symbol] key Item key to find.
        #
        # @note Instance must implement:
        #   * `find_output(collection, query)`
        def find_config key
          value = find_output config_collection, '_id' => key
          value ||= {'_collection' => config_collection, '_id' => key}
        end
      end
    end
  end
end
