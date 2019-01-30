require 'test_helper'

describe 'context integrator' do
  before do
    @object = Object.new
    class << @object
      include AeEasy::Core::Plugin::ContextIntegrator
    end
  end

  describe 'integration test' do
    it 'should mock context' do
      source = Object.new
      class << source
        define_method :my_test, lambda{|text|"hello world #{text}"}
      end
      @object.mock_context source
      assert_equal @object.my_test('test'), 'hello world test'
    end

    it 'should mock context with initialize hook' do
      source = Object.new
      class << source
        define_method :my_test, lambda{|text|"hello world #{text}"}
      end
      @object.initialize_hook_core_context_integrator context: source
      assert_equal @object.my_test('test'), 'hello world test'
    end
  end
end
