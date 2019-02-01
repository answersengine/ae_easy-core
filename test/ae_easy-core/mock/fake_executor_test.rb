require 'test_helper'

describe 'fake executor' do
  before do
    @executor = AeEasy::Core::Mock::FakeExecutor.new
  end

  describe 'unit test' do
    it 'should create uuid' do
      uuid_a = AeEasy::Core::Mock::FakeExecutor.fake_uuid
      uuid_b = AeEasy::Core::Mock::FakeExecutor.fake_uuid
      refute_equal uuid_a, uuid_b
      assert_kind_of String, uuid_a
      assert_kind_of String, uuid_b
      assert_operator uuid_a.length, :>, 0
      assert_operator uuid_b.length, :>, 0
    end

    it 'should create new collections with array keys and values' do
      keys = ['id', 'abc']
      values = [
        {'id' => 1, 'abc' => 'a', 'aaa' => 111},
        {'id' => 2, 'abc' => 'a', 'bbb' => 222},
        {'id' => 1, 'abc' => 'b', 'ccc' => 333},
        {'id' => 2, 'abc' => 'b', 'ddd' => 444},
        {'id' => 1, 'abc' => 'a', 'eee' => 555}
      ]
      data = AeEasy::Core::Mock::FakeExecutor.new_collection keys, values
      expected = [
        {'id' => 2, 'abc' => 'a', 'bbb' => 222},
        {'id' => 1, 'abc' => 'b', 'ccc' => 333},
        {'id' => 2, 'abc' => 'b', 'ddd' => 444},
        {'id' => 1, 'abc' => 'a', 'eee' => 555}
      ]
    end

    it 'should create new collections with hash keys and array values' do
      count = 0
      keys = {
        'id' => nil,
        'abc' => 'a',
        'count' => lambda{count += 1}
      }
      values = [
        {'id' => 1, 'abc' => 'a', 'aaa' => 111},
        {'id' => 2, 'bbb' => 222},
        {'id' => 1, 'abc' => 'b', 'ccc' => 333},
        {'id' => 2, 'abc' => 'b', 'ddd' => 444},
        {'id' => 1, 'abc' => 'a', 'eee' => 555}
      ]
      data = AeEasy::Core::Mock::FakeExecutor.new_collection keys, values
      expected = [
        {'id' => 2, 'abc' => 'a', 'count' => 2, 'bbb' => 222},
        {'id' => 1, 'abc' => 'b', 'count' => 3, 'ccc' => 333},
        {'id' => 2, 'abc' => 'b', 'count' => 4, 'ddd' => 444},
        {'id' => 1, 'abc' => 'a', 'count' => 5, 'eee' => 555}
      ]
    end

    it 'should clear output drafts and no saving output drafts' do
      @executor.outputs << {
        '_id' => '1',
        '_collection' => 'abc',
        'aaa' => 111
      }
      @executor.outputs << {
        '_id' => '2',
        '_collection' => 'abc',
        'aaa' => 222
      }
      expected = [
        {
          '_id' => '1',
          '_collection' => 'abc',
          'aaa' => 111
        },
        {
          '_id' => '2',
          '_collection' => 'abc',
          'aaa' => 222
        }
      ]
      assert_equal @executor.outputs, expected
      assert_empty @executor.saved_outputs
      @executor.clear_draft_outputs
      assert_empty @executor.outputs
      assert_empty @executor.saved_outputs
    end

    it 'should clear page drafts and no saving page drafts' do
      @executor.pages << {'url' => 'https://aaa.com'}
      @executor.pages << {'url' => 'https://bbb.com'}
      expected_pages = [
        {'url' => 'https://aaa.com'},
        {'url' => 'https://bbb.com'}
      ]
      assert_equal @executor.pages, expected_pages
      assert_empty @executor.saved_pages
      @executor.clear_draft_pages
      assert_empty @executor.pages
      assert_empty @executor.saved_pages
    end
  end

  describe 'integration test' do
  end
end
