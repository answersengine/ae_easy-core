module AeEasy
  module Core
    module Plugin
      module CollectionVault
        # Stored collections info as hash.
        def collections
          @collections ||= {}
        end

        # Add a new collection
        #
        # @param [Symbol] key Collection key used to lookup for collection name.
        # @param [String] name Collection name used on outputs.
        def add_collection key, name
          if collections.has_key? key
            raise "Can't add \"#{key}\" collection, it already exists!"
          end
          collections[key] = name
        end
      end
    end
  end
end
