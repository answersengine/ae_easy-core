require 'test_helper'

describe 'ae_easy-core' do
  it 'should get gem root correctly' do
    root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    assert_equal AeEasy::Core.gem_root, root
  end

  it 'should list all scripts from directory' do
    directory = File.expand_path('./test/fake_scripts/group_a')
    file_list = AeEasy::Core.all_scripts(directory)
    expected = [
      File.expand_path('./test/fake_scripts/group_a/script_a.rb'),
      File.expand_path('./test/fake_scripts/group_a/script_b.rb'),
      File.expand_path('./test/fake_scripts/group_a/script_c.rb')
    ]
    assert_equal expected.sort, file_list.sort
  end

  it 'should list all scripts from directory except script_a' do
    directory = File.expand_path('./test/fake_scripts/group_a')
    self_script = 'script_a.rb'
    file_list = AeEasy::Core.all_scripts directory, except: [self_script]
    expected = [
      File.expand_path('./test/fake_scripts/group_a/script_b.rb'),
      File.expand_path('./test/fake_scripts/group_a/script_c.rb')
    ]
    assert_equal expected.sort, file_list.sort
  end

  it 'should require all scripts with except' do
    out, err = capture_io do
      AeEasy::Core.require_all 'fake_scripts/group_a', except: ['script_c']
    end
    assert_match /Hello group A script A!/i, out
    assert_match /Hello group A script B!/i, out
    refute_match /Hello group A script C!/i, out
  end

  it 'should require relative all scripts from subdirectories with except' do
    out, err = capture_io do
      AeEasy::Core.require_relative_all './test/fake_scripts/group_d/**/', except: ['script_b']
    end
    assert_match /Hello group D sub sub_a script A!/i, out
    refute_match /Hello group D sub_b script B!/i, out
    assert_match /Hello group D sub script C!/i, out
    assert_match /Hello group D script D!/i, out
  end

  it 'should require all scripts from subdirectories with except' do
    out, err = capture_io do
      AeEasy::Core.require_all 'fake_scripts/group_c/**/', except: ['script_b']
    end
    assert_match /Hello group C sub sub_a script A!/i, out
    refute_match /Hello group C sub_b script B!/i, out
    assert_match /Hello group C sub script C!/i, out
    assert_match /Hello group C script D!/i, out
  end

  it 'should require relative all scripts with except' do
    out, err = capture_io do
      AeEasy::Core.require_relative_all './test/fake_scripts/group_b', except: ['script_c']
    end
    assert_match /Hello group B script A!/i, out
    assert_match /Hello group B script B!/i, out
    refute_match /Hello group B script C!/i, out
  end

  it 'should expose an environment to an object' do
    env = {my_test: lambda{|text|"hello world #{text}"}}
    object = Object.new
    AeEasy::Core.expose_to object, env
    assert_equal object.my_test('test'), 'hello world test'
  end

  it 'should mock an instance methods into an object' do
    origin = Object.new
    class << origin
      define_method :my_test, lambda{|text|"hello world #{text}"}
    end
    target = Object.new
    AeEasy::Core.mock_instance_methods origin, target
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
    assert_equal expected.sort, data.sort
  end

  it 'should analyze compatibility when uncompatible fragment' do
    data = AeEasy::Core.analyze_compatibility [1,2,3,4,5], [1,2,6]
    expected = {
      missing: [6],
      new: [3,4,5],
      is_compatible: false
    }
    assert_equal expected, data
  end

  it 'should analyze compatibility when compatible fragment' do
    data = AeEasy::Core.analyze_compatibility [1,2,3,4,5], [1,2,3]
    expected = {
      missing: [],
      new: [4,5],
      is_compatible: true
    }
    assert_equal expected, data
  end

  it 'should analyze compatibility when equal' do
    data = AeEasy::Core.analyze_compatibility [1,2,3], [1,2,3]
    expected = {
      missing: [],
      new: [],
      is_compatible: true
    }
    assert_equal expected, data
  end

  it 'should deep stringify a hash with clone' do
    hash = {
      'aaa' => {
        bbb: 222,
        'ccc': 333,
        'ddd' => 444,
        eee: {
          'fff' => 777,
          'ggg': {
            hhh: '888'
          }
        },
        jjj: [
          {'kkk' => 111},
          {lll: {mmm: 'MMM'}}
        ]
      },
      _iii: 'III'
    }
    data = AeEasy::Core.deep_stringify_keys hash
    expected = {
      'aaa' => {
        'bbb' => 222,
        'ccc' => 333,
        'ddd' => 444,
        'eee' => {
          'fff' => 777,
          'ggg' => {
            'hhh' => '888'
          }
        },
        'jjj' => [
          {'kkk' => 111},
          {'lll' => {'mmm' => 'MMM'}}
        ]
      },
      '_iii' => 'III'
    }
    assert_equal expected, data
  end

  it 'should keep input hash without modification when deep stringify a hash with clone' do
    hash = {
      'aaa' => {
        bbb: 222,
        'ccc': 333,
        'ddd' => 444,
        eee: {
          'fff' => 777,
          'ggg': {
            hhh: '888'
          }
        }
      },
      _iii: 'III'
    }
    AeEasy::Core.deep_stringify_keys hash
    expected = {
      'aaa' => {
        bbb: 222,
        'ccc': 333,
        'ddd' => 444,
        eee: {
          'fff' => 777,
          'ggg': {
            hhh: '888'
          }
        }
      },
      _iii: 'III'
    }
    assert_equal expected, hash
  end

  it 'should deep stringify a hash without clone' do
    hash = {
      'aaa' => {
        bbb: 222,
        'ccc': 333,
        'ddd' => 444,
        eee: {
          'fff' => 777,
          'ggg': {
            hhh: '888'
          }
        }
      },
      _iii: 'III'
    }
    data = AeEasy::Core.deep_stringify_keys hash, false
    expected = {
      'aaa' => {
        'bbb' => 222,
        'ccc' => 333,
        'ddd' => 444,
        'eee' => {
          'fff' => 777,
          'ggg' => {
            'hhh' => '888'
          }
        }
      },
      '_iii' => 'III'
    }
    assert_equal expected, data
  end

  it 'should modify input hash when deep stringify a hash without clone' do
    hash = {
      'aaa' => {
        bbb: 222,
        'ccc': 333,
        'ddd' => 444,
        eee: {
          'fff' => 777,
          'ggg': {
            hhh: '888'
          }
        }
      },
      _iii: 'III'
    }
    data = AeEasy::Core.deep_stringify_keys hash, false
    expected = {
      'aaa' => {
        'bbb' => 222,
        'ccc' => 333,
        'ddd' => 444,
        'eee' => {
          'fff' => 777,
          'ggg' => {
            'hhh' => '888'
          }
        }
      },
      '_iii' => 'III'
    }
    assert_equal expected, hash
  end

  it 'should deep stringify into hash' do
    hash = {
      'aaa' => {
        bbb: 222,
        'ccc': 333,
        'ddd' => 444,
        eee: {
          'fff' => 777,
          'ggg': {
            hhh: '888'
          }
        }
      },
      _iii: 'III'
    }
    data = AeEasy::Core.deep_stringify_keys! hash
    expected = {
      'aaa' => {
        'bbb' => 222,
        'ccc' => 333,
        'ddd' => 444,
        'eee' => {
          'fff' => 777,
          'ggg' => {
            'hhh' => '888'
          }
        }
      },
      '_iii' => 'III'
    }
    assert_equal data, hash
    assert_equal expected, hash
  end

  it 'should deep clone a hash while keep deep value references' do
    hash = {
      'level1A' => 333,
      'level1B' => {
        'level2A' => {
          level3A: [1,2,3],
          'level3B' => 222
        }
      }
    }
    data = AeEasy::Core.deep_clone hash
    data['level1A'] = 444
    data['level1B']['level2A'][:level3A].pop
    data['level1C'] = 'CCC'
    expected_input = {
      'level1A' => 333,
      'level1B' => {
        'level2A' => {
          level3A: [1,2],
          'level3B' => 222
        }
      }
    }
    expected_result = {
      'level1A' => 444,
      'level1B' => {
        'level2A' => {
          level3A: [1,2],
          'level3B' => 222
        }
      },
      'level1C' => 'CCC'
    }
    assert_equal expected_input, hash
    assert_equal expected_result, data
  end

  it 'should deep clone a hash while clone deep values' do
    hash = {
      'level1A' => 333,
      'level1B' => {
        'level2A' => {
          level3A: [1,2,3],
          'level3B' => 222
        }
      }
    }
    data = AeEasy::Core.deep_clone hash, true
    data['level1A'] = 444
    data['level1B']['level2A'][:level3A].pop
    data['level1C'] = 'CCC'
    expected_input = {
      'level1A' => 333,
      'level1B' => {
        'level2A' => {
          level3A: [1,2,3],
          'level3B' => 222
        }
      }
    }
    expected_result = {
      'level1A' => 444,
      'level1B' => {
        'level2A' => {
          level3A: [1,2],
          'level3B' => 222
        }
      },
      'level1C' => 'CCC'
    }
    assert_equal expected_input, hash
    assert_equal expected_result, data
  end
end
