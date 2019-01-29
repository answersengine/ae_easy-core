module AeEasy
  module Core
    module Plugin
      module SeederBehavior
        include AeEasy::Core::Plugin::ContextIntegrator

        def enqueue pages
          pages = [pages] unless pages.is_a? Array
          save_pages pages
        end
      end
    end
  end
end
