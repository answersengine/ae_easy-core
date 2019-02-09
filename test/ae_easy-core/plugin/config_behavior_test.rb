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

    it 'should generate an initial config value when not exists' do
      class << @object
        define_method(:find_output){|collection, filter|nil}
      end
      @object.initialize_hook_core_config_behavior
      data = @object.find_config 'aaa'
      expected = {'_collection' => 'config', '_id' => 'aaa'}
      assert_equal expected, data
    end

    it 'should generate an initial config value when not exists' do
      class << @object
        define_method(:find_output) do |collection, filter|
          filter.merge(
            '_collection' => collection,
            'bbb' => '222'
          )
        end
      end
      @object.initialize_hook_core_config_behavior
      data = @object.find_config 'aaa'
      expected = {
        '_collection' => 'config',
        '_id' => 'aaa',
        'bbb' => '222'
      }
      assert_equal expected, data
    end
  end
end
