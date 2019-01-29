require 'test_helper'

describe 'seeder' do
  before do
    # Parser object
    @object = Object.new
    class << @object
      include AeEasy::Core::Plugin::Seeder
    end

    @context, @message_queue = AeEasy::Core::Test::Helper.seeder_context_vars
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
      assert_equal mock_methods, expected_methods
    end
  end
end
