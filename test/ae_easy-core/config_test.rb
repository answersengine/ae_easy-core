require 'test_helper'

describe 'config' do
  before do
    @context = Object.new
  end

  describe 'unit test' do
    it 'should initialize without custom collection' do
      config = AeEasy::Core::Config.new context: @context
      assert_kind_of AeEasy::Core::Config, config
      assert_equal 'config', config.collection
    end

    it 'should initialize with custom collection' do
      config = AeEasy::Core::Config.new context: @context,
        collection: [:aaa, 'BBB']
      assert_kind_of AeEasy::Core::Config, config
      assert_equal :aaa, config.collection_key
      assert_equal 'BBB', config.collection
    end
  end

  describe 'integration test' do
  end
end
