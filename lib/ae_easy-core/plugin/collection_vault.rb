module AeEasy
  module Core
    module Plugin
      module CollectionVault
        def collections
          @collections ||= {}
        end

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
