require 'test_helper'

describe 'executor' do
  before do
    # Executor object
    @object = Object.new
    class << @object
      include AeEasy::Core::Plugin::Executor
    end

    # Context
    exposed_methods = [:save_pages, :save_outputs]
    @context, @message_queue = AeEasy::Core::Mock.context_vars exposed_methods
  end

  describe 'integration test' do
    it 'should mock context on initialize' do
      default_methods = AeEasy::Core.instance_methods_from @object

      class << @object
        define_method :mock_initialize, lambda{|*args|initialize *args}
      end
      @object.mock_initialize context: @context
      mixed_methods = AeEasy::Core.instance_methods_from @object

      mock_methods = mixed_methods - default_methods - [:mock_initialize]
      expected_methods = AeEasy::Core.instance_methods_from @context
      assert_equal mock_methods.sort, expected_methods.sort
    end
  end
end
