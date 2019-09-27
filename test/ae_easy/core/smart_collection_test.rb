require 'test_helper'

describe 'smart collection' do
  describe 'unit test' do
    it 'should not match items correctly when equal and no keys' do
      keys = []
      item_a = {'aaa' => 111}
      item_b = {'aaa' => 111}
      data = AeEasy::Core::SmartCollection.new keys
      refute data.match_keys? item_a, item_b
    end

    it 'should not match items when different and no keys' do
      keys = []
      item_a = {'aaa' => 111}
      item_b = {'aaa' => 222}
      data = AeEasy::Core::SmartCollection.new keys
      refute data.match_keys? item_a, item_b
    end

    it 'should match items when same keys values' do
      keys = ['aaa', 'bbb']
      item_a = {'aaa' => 111, 'bbb' => 222, 'ddd' => 444}
      item_b = {'aaa' => 111, 'bbb' => 222, 'ccc' => 333}
      data = AeEasy::Core::SmartCollection.new keys
      assert data.match_keys? item_a, item_b
    end

    it 'should not match items when different keys values' do
      keys = ['aaa', 'bbb']
      item_a = {'aaa' => 111, 'bbb' => 555, 'ddd' => 444}
      item_b = {'aaa' => 111, 'bbb' => 222, 'ccc' => 333}
      data = AeEasy::Core::SmartCollection.new keys
      refute data.match_keys? item_a, item_b
    end

    it 'should not match items when item_a is nil' do
      keys = ['aaa', 'bbb']
      item_a = nil
      item_b = {'aaa' => 111, 'bbb' => 222, 'ccc' => 333}
      data = AeEasy::Core::SmartCollection.new keys
      refute data.match_keys? item_a, item_b
    end

    it 'should not match items when item_b is nil' do
      keys = ['aaa', 'bbb']
      item_a = {'aaa' => 111, 'bbb' => 222, 'ccc' => 333}
      item_b = nil
      data = AeEasy::Core::SmartCollection.new keys
      refute data.match_keys? item_a, item_b
    end

    it 'should initialize with keys only' do
      keys = [
        '_id',
        '_collection'
      ]
      data = AeEasy::Core::SmartCollection.new keys
      expected = [
        '_id',
        '_collection'
      ]
      assert_equal expected.sort, data.key_fields.sort
      assert_equal Hash.new, data.defaults
      assert_equal [], data
    end

    it 'should initialize with values only' do
      keys = []
      values = [
        {'aaa' => 111},
        {'aaa' => 222},
        {'bbb' => 333}
      ]
      data = AeEasy::Core::SmartCollection.new keys, values: values
      expected = [
        {'aaa' => 111},
        {'aaa' => 222},
        {'bbb' => 333}
      ]
      assert_equal [], data.key_fields
      assert_equal Hash.new, data.defaults
      assert_equal expected, data
    end

    it 'should initialize with defaults only' do
      keys = []
      defaults = {
        'aaa' => 111,
        'bbb' => 222,
        'ccc' => nil
      }
      data = AeEasy::Core::SmartCollection.new keys, defaults: defaults
      expected = {
        'aaa' => 111,
        'bbb' => 222,
        'ccc' => nil
      }
      assert_equal [], data.key_fields
      assert_equal expected, data.defaults
      assert_equal [], data
    end

    it 'should initialize with keys, defaults and values' do
      count = 0
      keys = [
        '_id',
        '_collection'
      ]
      defaults = {
        '_id' => lambda{|item|"id_#{count += 1}"},
        '_collection' => 'default',
        'abc' => nil
      }
      values = [
        {'aaa' => 111, '_collection' => 'abc'},
        {'bbb' => 222, 'abc' => 'hello'},
        {'ccc' => 333}
      ]
      data = AeEasy::Core::SmartCollection.new keys,
        defaults: defaults,
        values: values
      expected = [
        {
          '_id' => 'id_1',
          '_collection' => 'abc',
          'abc' => nil,
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
          'abc' => nil,
          'ccc' => 333
        }
      ]
      assert_equal expected, data
    end

    it 'should find and exsiting item match on filter match' do
      keys = ['id']
      values = [
        {'id' => 'AAA', 'aaa' => 'AAA'},
        {'id' => 'BBB', 'bbb' => 'BBB'},
        {'id' => 'CCC', 'ccc' => 'CCC'}
      ]
      filter = {'id' => 'BBB', 'my_ignored_filter' => 123}
      collection = AeEasy::Core::SmartCollection.new keys
      values.each{|i|collection << i}
      data = collection.find_match filter
      expected = {
        'id' => 'BBB',
        'bbb' => 'BBB'
      }
      assert_equal expected, data
    end

    it 'should not find any match on filter mismatch' do
      keys = ['id']
      values = [
        {'id' => 'AAA', 'aaa' => 'AAA'},
        {'id' => 'BBB', 'bbb' => 'BBB'},
        {'id' => 'CCC', 'ccc' => 'CCC'}
      ]
      filter = {'id' => 'DDD'}
      collection = AeEasy::Core::SmartCollection.new keys
      values.each{|i|collection << i}
      data = collection.find_match filter
      assert_nil data
    end

    it 'should raise error on bind event when unknown event' do
      assert_raises(ArgumentError, "Unknown event 'aaa'") do
        data = AeEasy::Core::SmartCollection.new []
        data.bind_event(:aaa){puts 'BBB'}
      end
    end

    describe 'should modify original item' do
      it 'with before_defaults bind' do
        executed = false
        defaults = {
          'aaa' => 111
        }
        value = {
          'bbb' => 222,
          'ddd' => 444
        }
        expected_before_defaults = {
          'bbb' => 222,
          'ddd' => 444
        }
        data = AeEasy::Core::SmartCollection.new [], defaults: defaults
        data.bind_event(:before_defaults) do |collection, item|
          executed = true
          assert_equal [], collection
          assert_equal expected_before_defaults, item
          item['aaa'] = 'AAA'
          item['ccc'] = 333
          item['ddd'] = 'DDD'
          item
        end
        data << value
        expected = [
          {
            'aaa' => 'AAA',
            'bbb' => 222,
            'ccc' => 333,
            'ddd' => 'DDD'
          }
        ]
        assert executed
        assert_equal expected, data
      end

      it 'with before_match bind' do
        executed = false
        defaults = {
          'aaa' => 111
        }
        value = {
          'bbb' => 222,
          'ddd' => 444
        }
        expected_before_match = {
          'aaa' => 111,
          'bbb' => 222,
          'ddd' => 444
        }
        data = AeEasy::Core::SmartCollection.new [], defaults: defaults
        data.bind_event(:before_match) do |collection, item|
          executed = true
          assert_equal [], collection
          assert_equal expected_before_match, item
          item['ccc'] = 333
          item['ddd'] = 'DDD'
          item
        end
        data << value
        expected = [
          {
            'aaa' => 111,
            'bbb' => 222,
            'ccc' => 333,
            'ddd' => 'DDD'
          }
        ]
        assert executed
        assert_equal expected, data
      end

      it 'with before_insert bind' do
        executed = false
        keys = ['id']
        defaults = {'ddd' => 444}
        value = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC'
        }
        expected_before_insert = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC',
          'ddd' => 444
        }
        data = AeEasy::Core::SmartCollection.new keys, defaults: defaults
        data.bind_event(:before_insert) do |collection, item, match|
          executed = true
          assert_equal [], collection
          assert_equal expected_before_insert, item
          assert_nil match
          item['ccc'] = 333
          item['ddd'] = 'DDD'
          item
        end
        data << value
        expected = [
          {
            'id' => 1,
            'bbb' => 'BBB',
            'ccc' => 333,
            'ddd' => 'DDD'
          }
        ]
        assert executed
        assert_equal expected, data
      end

      it 'with before_insert bind when existing matching item will be replaced' do
        executed = false
        keys = ['id']
        defaults = {'ddd' => 444}
        existing_value = {
          'id' => 1,
          'aaa' => 111,
          'ccc' => 333
        }
        value = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC'
        }
        expected_existing_item = {
          'id' => 1,
          'aaa' => 111,
          'ccc' => 333,
          'ddd' => 444
        }
        expected_before_insert = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC',
          'ddd' => 444
        }
        data = AeEasy::Core::SmartCollection.new keys, defaults: defaults
        data << existing_value
        data.bind_event(:before_insert) do |collection, item, match|
          executed = true
          assert_equal [expected_existing_item], collection
          assert_equal expected_before_insert, item
          assert_equal expected_existing_item, match
          item['ccc'] = 333
          item['ddd'] = 'DDD'
          item
        end
        data << value
        expected = [
          {
            'id' => 1,
            'bbb' => 'BBB',
            'ccc' => 333,
            'ddd' => 'DDD'
          }
        ]
        assert executed
        assert_equal expected, data
      end

      it 'with after_insert bind' do
        executed = false
        keys = ['id']
        defaults = {'ddd' => 444}
        value = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC'
        }
        expected_after_insert = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC',
          'ddd' => 444
        }
        data = AeEasy::Core::SmartCollection.new keys, defaults: defaults
        data.bind_event(:after_insert) do |collection, item|
          executed = true
          assert_equal [expected_after_insert], collection
          assert_equal expected_after_insert, item
          item['ccc'] = 333
          item['ddd'] = 'DDD'
        end
        data << value
        expected = [
          {
            'id' => 1,
            'bbb' => 'BBB',
            'ccc' => 333,
            'ddd' => 'DDD'
          }
        ]
        assert executed
        assert_equal expected, data
      end

      it 'with after_insert bind when existing matching item was replaced' do
        executed = false
        keys = ['id']
        defaults = {'ddd' => 444}
        existing_value = {
          'id' => 1,
          'aaa' => 111,
          'ccc' => 333
        }
        value = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC'
        }
        expected_existing_item = {
          'id' => 1,
          'aaa' => 111,
          'ccc' => 333,
          'ddd' => 444
        }
        expected_after_insert = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC',
          'ddd' => 444
        }
        data = AeEasy::Core::SmartCollection.new keys, defaults: defaults
        data << existing_value
        data.bind_event(:after_insert) do |collection, item, match|
          executed = true
          assert_equal [expected_after_insert], collection
          assert_equal expected_after_insert, item
          assert_equal expected_existing_item, match
          item['ccc'] = 333
          item['ddd'] = 'DDD'
        end
        data << value
        expected = [
          {
            'id' => 1,
            'bbb' => 'BBB',
            'ccc' => 333,
            'ddd' => 'DDD'
          }
        ]
        assert executed
        assert_equal expected, data
      end
    end

    describe 'should replace original item' do
      it 'with before_defaults bind' do
        executed = false
        defaults = {
          'aaa' => 111
        }
        value = {
          'bbb' => 222,
          'ddd' => 444
        }
        expected_before_defaults = {
          'bbb' => 222,
          'ddd' => 444
        }
        data = AeEasy::Core::SmartCollection.new [], defaults: defaults
        data.bind_event(:before_defaults) do |collection, item|
          executed = true
          assert_equal [], collection
          assert_equal expected_before_defaults, item
          # Replace inserted item
          {'eee' => 555}
        end
        data << value
        expected = [
          {
            'aaa' => 111,
            'eee' => 555
          }
        ]
        assert executed
        assert_equal expected, data
      end

      it 'with before_match bind' do
        executed = false
        defaults = {
          'aaa' => 111
        }
        value = {
          'bbb' => 222,
          'ddd' => 444
        }
        expected_before_match = {
          'aaa' => 111,
          'bbb' => 222,
          'ddd' => 444
        }
        data = AeEasy::Core::SmartCollection.new [], defaults: defaults
        data.bind_event(:before_match) do |collection, item|
          executed = true
          assert_equal [], collection
          assert_equal expected_before_match, item
          # Replace item
          {'eee' => 555}
        end
        data << value
        expected = [
          {'eee' => 555}
        ]
        assert executed
        assert_equal expected, data
      end

      it 'with before_insert bind' do
        executed = false
        keys = ['id']
        defaults = {'ddd' => 444}
        value = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC'
        }
        expected_before_insert = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC',
          'ddd' => 444
        }
        data = AeEasy::Core::SmartCollection.new keys, defaults: defaults
        data.bind_event(:before_insert) do |collection, item, match|
          executed = true
          assert_equal [], collection
          assert_equal expected_before_insert, item
          assert_nil match
          # Replace item
          {'id' => 2, 'eee' => 555}
        end
        data << value
        expected = [
          {
            'id' => 2,
            'eee' => 555
          }
        ]
        assert executed
        assert_equal expected, data
      end

      it 'with before_insert bind when existing matching item will be replaced' do
        executed = false
        keys = ['id']
        defaults = {'ddd' => 444}
        existing_value = {
          'id' => 1,
          'aaa' => 111,
          'ccc' => 333
        }
        value = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC'
        }
        expected_existing_item = {
          'id' => 1,
          'aaa' => 111,
          'ccc' => 333,
          'ddd' => 444
        }
        expected_before_insert = {
          'id' => 1,
          'bbb' => 'BBB',
          'ccc' => 'CCC',
          'ddd' => 444
        }
        data = AeEasy::Core::SmartCollection.new keys, defaults: defaults
        data << existing_value
        data.bind_event(:before_insert) do |collection, item, match|
          executed = true
          assert_equal [expected_existing_item], collection
          assert_equal expected_before_insert, item
          assert_equal expected_existing_item, match
          # Replace item
          {'id' => 2, 'eee' => 555}
        end
        data << value
        expected = [
          {
            'id' => 2,
            'eee' => 555
          }
        ]
        assert executed
        assert_equal expected, data
      end
    end
  end

  describe 'integration test' do
    it 'should insert item when different keys values' do
      count = 0
      keys = [
        '_id',
        '_collection'
      ]
      defaults = {
        '_collection' => 'default'
      }
      values = [
        {'_id' => 'AAA', 'aaa' => 111},
        {'_id' => 'BBB', 'aaa' => 222},
        {'_id' => 'CCC', 'aaa' => 333}
      ]
      data = AeEasy::Core::SmartCollection.new keys, defaults: defaults
      values.each{|i|data << i}
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
      assert_equal expected, data
    end

    it 'should replace item when same keys' do
      count = 0
      keys = [
        '_id',
        '_collection'
      ]
      defaults = {
        '_collection' => 'default'
      }
      values = [
        {'_id' => 'AAA', 'aaa' => 111},
        {'_id' => 'AAA', 'bbb' => 222},
        {'_id' => 'CCC', 'ccc' => 333}
      ]
      data = AeEasy::Core::SmartCollection.new keys, defaults: defaults
      values.each{|i|data << i}
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
      assert_equal expected, data
    end
  end
end
