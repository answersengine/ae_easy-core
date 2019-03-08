module AeEasy
  module Core
    module Plugin
      module ContextIntegrator
        # Last mocked ontext object.
        attr_reader :context

        # Mock a context methods into self.
        #
        # @param origin Object that represents the context to mock.
        #
        # @example
        #   class MyContext
        #     attr_accessor :message
        #     def initialize
        #       message = 'Hello world!'
        #     end
        #
        #     def hello_world
        #       message
        #     end
        #   end
        #
        #   class Foo
        #     include ContextIntegrator
        #
        #     def hello_person
        #       'Hello person!'
        #     end
        #   end
        #
        #   context = MyContext.new
        #   my_object = Foo.new
        #   my_object.mock_context context
        #
        #   puts my_object.hello_world
        #   # => 'Hello world!'
        #   puts my_object.hello_person
        #   # => 'Hello person!'
        #
        #   context.message = 'Hello world again!'
        #   puts my_object.hello_world
        #   # => 'Hello world again!
        def mock_context origin
          @context = origin
          AeEasy::Core.mock_instance_methods context, self
        end

        # Hook to mock context on initialize.
        #
        # @param [Hash] opts ({}) Configuration options.
        # @option opts :context Object that represents the context to mock.
        def initialize_hook_core_context_integrator opts = [{}]
          raise ':context object is required.' if opts[:context].nil?
          mock_context opts[:context]
        end
      end
    end
  end
end
