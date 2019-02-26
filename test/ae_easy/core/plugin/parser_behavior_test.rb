require 'test_helper'

describe 'parser behavior' do
  before do
    # Parser behavior object
    @object = Object.new
    class << @object
      include AeEasy::Core::Plugin::ParserBehavior
    end

    # Parser context
    exposed_methods = AnswersEngine::Scraper::RubyParserExecutor.exposed_methods
    @context, @message_queue = AeEasy::Core::Mock.context_vars exposed_methods
  end

  describe 'integration test' do
    it 'should mock context' do
      default_methods = AeEasy::Core.instance_methods_from @object

      @object.mock_context @context
      mixed_methods = AeEasy::Core.instance_methods_from @object

      mock_methods = mixed_methods - default_methods
      expected_methods = AeEasy::Core.instance_methods_from @context
      assert_equal mock_methods.sort, expected_methods.sort
    end
  end

  describe 'unit test' do
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
