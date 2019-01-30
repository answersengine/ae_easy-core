require 'test_helper'

describe 'fake executor' do
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

    id 'should create new collections with keys and values' do
      keys = ['id', 'abc']
      values = [
        {'id' => 1, 'abc' => 'a'},
        {'id' => 2, 'abc' => 'a'},
        {'id' => 1, 'abc' => 'b'},
        {'id' => 2, 'abc' => 'b'}
      ]
      collection AeEasy::Core::Mock::FakeExecutor.new_collection keys, values
    end
  end

  describe 'integration test' do
  end
end
