require 'test_helper'

describe 'core' do
  it 'should get gem root correctly' do
    root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    assert_equal AeEasy::Core.gem_root, root
  end

  it 'should list all scripts from directory' do
    directory = File.expand_path(File.dirname(__FILE__))
    file_list = AeEasy::Core.all_scripts(directory)
    expected = Dir[File.join(directory, '*.rb')]
    assert_equal file_list, expected
  end

  it 'should list all scripts from directory except self' do
    directory = File.expand_path(File.dirname(__FILE__))
    self_script = File.expand_path(__FILE__)
    file_list = AeEasy::Core.all_scripts directory, except: [self_script]
    expected = Dir[File.join(directory, '*.rb')] - [self_script]
    assert_equal file_list, expected
  end

  it 'should expose an environment to an object' do
    env = {my_test: lambda{|text|"hello world #{text}"}}
    object = Object.new
    AeEasy::Core.expose_to object, env
    assert_equal object.my_test('test'), 'hello world test'
  end

  it 'should mock an instance methods into an object' do
    source = Object.new
    class << source
      define_method :my_test, lambda{|text|"hello world #{text}"}
    end
    target = Object.new
    AeEasy::Core.mock_instance_methods source, target
    assert_equal target.my_test('test'), 'hello world test'
  end

  it 'should extract an object instance methods' do
    object = Object.new
    class << object
      define_method :my_test_a, lambda{}
      define_method :my_test_b, lambda{}
    end
    expected = [
      :my_test_a,
      :my_test_b
    ]
    data = AeEasy::Core.instance_methods_from object
    assert_equal data, expected
  end
end
