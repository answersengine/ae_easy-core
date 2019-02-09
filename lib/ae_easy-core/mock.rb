require 'ae_easy-core/mock/fake_db'
require 'ae_easy-core/mock/fake_executor'
require 'ae_easy-core/mock/fake_parser'
require 'ae_easy-core/mock/fake_seeder'

module AeEasy
  module Core
    module Mock
      # Generate a context and message queue from a list of exposed methods.
      #
      # @param [Array] exposed_methods List of exposed methods.
      #
      # @example
      #   exposed_methods = [:boo, :bar]
      #   context, message_queue = AeEasy::Core::Mock.context_vars exposed_methods
      #   context.boo 1, 2
      #   context.bar 'A', 'B'
      #   context.bar '111', '222'
      #   message_queue
      #   # => [
      #   #   [:boo, [1, 2]],
      #   #   [:bar, ['A', 'B']],
      #   #   [:bar, ['111', '222']]
      #   # ]
      #
      # @return [Array] `[context, message_queue]` being:
      #   * `context`: Object implementing exposed methods.
      #   * `[Array] message_queue`: Array to store messages.
      def self.context_vars exposed_methods
        context = Object.new
        metaclass = class << context; self; end
        message_queue = [] # Beat reference bug
        exposed_methods = exposed_methods
        exposed_methods.each do |key|
          metaclass.send(:define_method, key) do |*args|
            # Record all method calls into message queue for easy access
            message_queue << [key, args]
          end
        end
        [context, message_queue]
      end
    end
  end
end
