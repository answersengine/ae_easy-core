module AeEasy
  module Core
    module Plugin
      module ParserBehavior
        include AeEasy::Core::Plugin::ContextIntegrator

        def enqueue pages
          pages = [pages] unless pages.is_a? Array
          save_pages pages
        end

        def save outputs
          outputs = [outputs] unless outputs.is_a? Array
          save_outputs outputs
        end

        def vars
          page['vars']
        end
      end
    end
  end
end
