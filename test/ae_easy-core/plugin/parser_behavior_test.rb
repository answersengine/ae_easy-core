require 'test_helper'

describe 'parser behavior' do
  before do
    # Parser behavior object
    @object = Object.new
    class << @object
      include AeEasy::Core::Plugin::ParserBehavior
    end

    # Parser context
    @context, @message_queue = AeEasy::Core::Test::Helper.parser_context_vars
  end

  describe 'integration test' do
    it 'should mock context' do
      default_methods = AeEasy::Core.instance_methods_from @object

      @object.mock_context @context
      mixed_methods = AeEasy::Core.instance_methods_from @object

      mock_methods = mixed_methods - default_methods
      expected_methods = AeEasy::Core.instance_methods_from @context
      assert_equal mock_methods, expected_methods
    end
  end

  describe 'unit test' do
    it 'should enqueue a single page' do
      page = {
        'gid' => 123,
        'url' => 'http://example.com',
        'vars' => {
          'aaa' => 'AAA',
          'bbb' => '222'
        }
      }
      @object.mock_context @context
      @object.enqueue page
      expected = [
        [:save_pages, [[{
          'gid' => 123,
          'url' => 'http://example.com',
          'vars' => {
            'aaa' => 'AAA',
            'bbb' => '222'
          }
        }]]]
      ]
      assert_equal @message_queue, expected
    end

    it 'should enqueue a collection of pages' do
      pages = [
        {
          'gid' => 111,
          'url' => 'http://example.com',
          'vars' => {
            'aaa' => 'AAA',
            'bbb' => '222'
          }
        },
        {
          'gid' => 222,
          'url' => 'http://example.com/abc',
          'vars' => {
            'ccc' => '333',
            'ddd' => 'DEF'
          }
        }
      ]
      @object.mock_context @context
      @object.enqueue pages

      expected = [
        [:save_pages, [[
          {
            'gid' => 111,
            'url' => 'http://example.com',
            'vars' => {
              'aaa' => 'AAA',
              'bbb' => '222'
            }
          },
          {
            'gid' => 222,
            'url' => 'http://example.com/abc',
            'vars' => {
              'ccc' => '333',
              'ddd' => 'DEF'
            }
          }
        ]]]
      ]
      assert_equal @message_queue, expected
    end

    it 'should save a single output' do
      output = {
        '_id' => 'abc123',
        'value_a' => 'hello world',
        'value_b' => 123,
        'value_c' => true
      }
      @object.mock_context @context
      @object.save output

      expected = [
        [:save_outputs, [[{
          '_id' => 'abc123',
          'value_a' => 'hello world',
          'value_b' => 123,
          'value_c' => true
        }]]]
      ]
      assert_equal @message_queue, expected
    end

    it 'should save a collection of outputs' do
      outputs = [
        {
          '_id' => 'abc123',
          'value_a' => 'hello world',
          'value_b' => 123,
          'value_c' => true
        },
        {
          '_id' => 'def456',
          'value_a' => 'my message',
          'value_d' => ['AAA', 'BBB'],
          'value_e' => 456
        }
      ]
      @object.mock_context @context
      @object.save outputs

      expected = [
        [:save_outputs, [[
          {
            '_id' => 'abc123',
            'value_a' => 'hello world',
            'value_b' => 123,
            'value_c' => true
          },
          {
            '_id' => 'def456',
            'value_a' => 'my message',
            'value_d' => ['AAA', 'BBB'],
            'value_e' => 456
          }
        ]]]
      ]
      assert_equal @message_queue, expected
    end

    it 'should get page vars' do
      page = {
        'gid' => 123,
        'url' => 'http://example.com',
        'vars' => {
          'aaa' => 'AAA',
          'bbb' => '222'
        }
      }
      metaclass = (class << @object; self; end)
      metaclass.send(:define_method, :page){page}
      expected = {
        'aaa' => 'AAA',
        'bbb' => '222'
      }
      assert_equal @object.vars, expected
    end
  end
end
