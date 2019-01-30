require 'test_helper'

describe 'config behavior' do
  before do
    # Config behavior object
    @object = Object.new
    class << @object
      include AeEasy::Core::Plugin::ConfigBehavior
    end
  end

  describe 'unit test' do
  end

  describe 'integration test' do
    describe 'with default collection' do
      it 'should initialize collection list' do
        @object.initialize_hook_core_config_behavior
        expected = {config: 'config'}
        assert_equal @object.collections, expected
      end

      it 'should initialize collection name' do
        @object.initialize_hook_core_config_behavior
        expected = 'config'
        assert_equal @object.config_collection, expected
      end
    end

    describe 'with custom collection' do
      it 'should initialize collection list' do
        @object.initialize_hook_core_config_behavior(
          config_collection: [:my_config, 'abc_config']
        )
        expected = {my_config: 'abc_config'}
        assert_equal @object.collections, expected
      end

      it 'should initialize collection name' do
        @object.initialize_hook_core_config_behavior(
          config_collection: [:my_config, 'abc_config']
        )
        expected = 'abc_config'
        assert_equal @object.config_collection, expected
      end
    end

    it 'should find a config value' do
      # context = AeEasy::Core::Test::Helper.parser_context_vars
      # outputs = []
      # find_ouput = lambda do |collection, filter|
      #   outputs.each do |output|
      #     match = true
      #     filter.each{|k,v| match = false if output[k] != v}
      #     return output if match
      #   end
      #   nil
      # end
      # class << context
      #   define_method :find_output, lambda do|collection, |outputs.find{||}}
      # end
      # @object.mock
    end
  end
end
