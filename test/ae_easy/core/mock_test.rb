require 'test_helper'

describe 'mock' do
  describe 'unit test' do
    it 'should create context and message queue from exposed methods' do
      exposed_methods = [:boo, :bar]
      context, message_queue = AeEasy::Core::Mock.context_vars exposed_methods
      context.boo 1, 2
      context.bar 'A', 'B'
      context.bar '111', '222'
      context_methods = context.methods(false) - Object.new.methods(false)
      expected = [
        [:boo, [1, 2]],
        [:bar, ['A', 'B']],
        [:bar, ['111', '222']]
      ]
      assert_equal [:bar, :boo], context_methods.sort
      assert_equal expected, message_queue
    end
  end

  describe 'integration test' do
  end
end
