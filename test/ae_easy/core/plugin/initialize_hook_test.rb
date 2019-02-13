require 'test_helper'

describe 'initialize hook' do
  before do
    # Initialize hook object
    @object = Object.new
    class << @object
      include AeEasy::Core::Plugin::InitializeHook
    end
  end

  describe 'unit test' do
    it 'should execute hooks' do
      metaclass = class << @object; self; end
      message_queue = []
      metaclass.send :define_method, :initialize_hook_my_hook_a, lambda{|opts|message_queue << opts[:message_a]}
      metaclass.send :define_method, :initialize_hook_my_hook_b, lambda{|opts|message_queue << opts[:message_b]}
      metaclass.send :define_method, :initialize_hook_my_hook_c, lambda{|opts|message_queue << opts[:message_c]}
      @object.initialize_hooks(
        message_a: 'Hello letter A',
        message_b: 'Hello letter B',
        message_c: 'Hello letter C'
      )
      expected = [
        'Hello letter A',
        'Hello letter B',
        'Hello letter C'
      ]
      assert_equal message_queue.sort, expected.sort
    end
  end
end
