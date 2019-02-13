require 'test_helper'

describe 'collection vault' do
  before do
    @vault = Object.new
    class << @vault
      include AeEasy::Core::Plugin::CollectionVault
    end
  end

  describe 'unit test' do
    it 'should not add new collection with previous key' do
      @vault.add_collection :my_collection_a, 'aaa_collection'
      @vault.add_collection :my_collection_b, 'bbb_collection'
      expected = {
        my_collection_a: 'aaa_collection',
        my_collection_b: 'bbb_collection'
      }
      assert_equal @vault.collections, expected
    end

    it 'should add new collection with not previous key' do
      assert_raises do
        @vault.add_collection :my_collection_a, 'aaa_collection'
        @vault.add_collection :my_collection_a, 'bbb_collection'
      end
    end
  end
end
