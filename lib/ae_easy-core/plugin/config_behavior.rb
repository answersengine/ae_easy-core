module AeEasy
  module Core
    module Plugin
      module ConfigBehavior
        attr_reader :config_collection_key

        include AeEasy::Core::Plugin::ContextIntegrator
        include AeEasy::Core::Plugin::CollectionVault

        def initialize_hook_config_behavior opts
          @config_collection_key, collection = opts[:config_collection] || [:config, 'config']
          add_collection config_collection_key, collection
        end

        def config_collection
          collections[config_collection_key]
        end

        def find_config key
          value = find_output config_collection, '_id' => key
          value ||= {'_collection' => config_collection, '_id' => key}
        end
      end
    end
  end
end
