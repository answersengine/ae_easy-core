module AeEasy
  module Core
    module Plugin
      module SeederBehavior
        include AeEasy::Core::Plugin::ContextIntegrator

        # {AeEasy::Core::Plugin::ParserBehavior#enqueue}
        def enqueue pages
          pages = [pages] unless pages.is_a? Array
          save_pages pages
        end

        # {AeEasy::Core::Plugin::ParserBehavior#save}
        def save outputs
          outputs = [outputs] unless outputs.is_a? Array
          save_outputs outputs
        end
      end
    end
  end
end
