module AeEasy
  module Core
    module Plugin
      module Parser
        include AeEasy::Core::Plugin::InitializeHook
        include AeEasy::Core::Plugin::ParserBehavior

        def initialize opts = {}
          initialize_hooks opts
        end
      end
    end
  end
end
