require 'test_helper'

describe 'smart collection' do
  describe 'unit test' do
    it 'should not match items correctly when equal and no keys' do
      keys = {}
      item_a = {'aaa' => 111}
      item_b = {'aaa' => 111}
      data = AeEasy::Core::SmartCollection.new keys
      refute data.match_keys? item_a, item_b
    end

    it 'should not match items when different and no keys' do
      keys = {}
      item_a = {'aaa' => 111}
      item_b = {'aaa' => 222}
      data = AeEasy::Core::SmartCollection.new keys
      refute data.match_keys? item_a, item_b
    end

    it 'should match items when same keys values' do
      keys = {'aaa' => nil, 'bbb' => nil}
      item_a = {'aaa' => 111, 'bbb' => 222, 'ddd' => 444}
      item_b = {'aaa' => 111, 'bbb' => 222, 'ccc' => 333}
      data = AeEasy::Core::SmartCollection.new keys
      assert data.match_keys? item_a, item_b
    end

    it 'should not match items when different keys values' do
      keys = {'aaa' => nil, 'bbb' => nil}
      item_a = {'aaa' => 111, 'bbb' => 555, 'ddd' => 444}
      item_b = {'aaa' => 111, 'bbb' => 222, 'ccc' => 333}
      data = AeEasy::Core::SmartCollection.new keys
      refute data.match_keys? item_a, item_b
    end

    it 'should not match items when item_a is nil' do
      keys = {'aaa' => nil, 'bbb' => nil}
      item_a = nil
      item_b = {'aaa' => 111, 'bbb' => 222, 'ccc' => 333}
      data = AeEasy::Core::SmartCollection.new keys
      refute data.match_keys? item_a, item_b
    end

    it 'should not match items when item_b is nil' do
      keys = {'aaa' => nil, 'bbb' => nil}
      item_a = {'aaa' => 111, 'bbb' => 222, 'ccc' => 333}
      item_b = nil
      data = AeEasy::Core::SmartCollection.new keys
      refute data.match_keys? item_a, item_b
    end

    it 'should initialize with keys only' do
      keys = {
        '_id' => nil,
        '_collection' => nil,
      }
      data = AeEasy::Core::SmartCollection.new keys
      assert_equal data.key_fields, keys
      assert_equal data, []
    end

    it 'should initialize with values only' do
      keys = {}
      values = [
        {'aaa' => 111},
        {'aaa' => 222},
        {'bbb' => 333}
      ]
      data = AeEasy::Core::SmartCollection.new keys, values
      assert_equal data.key_fields, {}
      assert_equal data, values
    end

    it 'should initialize with keys and values' do
      count = 0
      keys = {
        '_id' => lambda{"id_#{count += 1}"},
        '_collection' => 'default',
        'abc' => nil
      }
      values = values = [
        {'aaa' => 111, '_collection' => 'abc'},
        {'bbb' => 222, 'abc' => 'hello'},
        {'ccc' => 333}
      ]
      data = AeEasy::Core::SmartCollection.new keys, values
      expected = [
        {
          '_id' => 'id_1',
          '_collection' => 'abc',
          'aaa' => 111
        },
        {
          '_id' => 'id_2',
          '_collection' => 'default',
          'abc' => 'hello',
          'bbb' => 222
        },
        {
          '_id' => 'id_3',
          '_collection' => 'default',
          'ccc' => 333
        }
      ]
      assert_equal data, expected
    end

    it 'should insert item when different keys values' do
      count = 0
      keys = {
        '_id' => nil,
        '_collection' => 'default'
      }
      values = values = [
        {'_id' => 'AAA', 'aaa' => 111},
        {'_id' => 'BBB', 'aaa' => 222},
        {'_id' => 'CCC', 'aaa' => 333}
      ]
      data = AeEasy::Core::SmartCollection.new keys, values
      expected = [
        {
          '_id' => 'AAA',
          '_collection' => 'default',
          'aaa' => 111
        },
        {
          '_id' => 'BBB',
          '_collection' => 'default',
          'aaa' => 222
        },
        {
          '_id' => 'CCC',
          '_collection' => 'default',
          'aaa' => 333
        }
      ]
      assert_equal data, expected
    end

    it 'should replace item when same keys' do
      count = 0
      keys = {
        '_id' => nil,
        '_collection' => 'default'
      }
      values = values = [
        {'_id' => 'AAA', 'aaa' => 111},
        {'_id' => 'AAA', 'bbb' => 222},
        {'_id' => 'CCC', 'ccc' => 333}
      ]
      data = AeEasy::Core::SmartCollection.new keys, values
      expected = [
        {
          '_id' => 'AAA',
          '_collection' => 'default',
          'bbb' => 222
        },
        {
          '_id' => 'CCC',
          '_collection' => 'default',
          'ccc' => 333
        }
      ]
      assert_equal data, expected
    end
  end

  describe 'integration test' do
  end
end
