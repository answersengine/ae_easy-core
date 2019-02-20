require 'test_helper'

describe 'fake seeder' do
  before do
    @executor = AeEasy::Core::Mock::FakeSeeder.new
  end

  describe 'unit test' do
    it 'should expose methods' do
      data = verbose = nil
      begin
        verbose = $VERBOSE
        $VERBOSE = true
        out, err = capture_io do
          data = AeEasy::Core::Mock::FakeSeeder.exposed_methods
        end
        $VERBOSE = verbose
      ensure
        $VERBOSE = verbose unless verbose.nil?
      end
      expected = [
        :outputs,
        :pages,
        :save_pages,
        :save_outputs,
        :find_output,
        :find_outputs
      ]
      assert_empty err
      assert_equal expected.sort, data.sort
    end
  end

  describe 'integration test' do
    it 'should execute script with context and flush correctly' do
      expected_find_output = nil
      expected_find_outputs = nil
      vars = {
        mock_set_find_output: lambda{|v|expected_find_output = v},
        mock_set_find_outputs: lambda{|v|expected_find_outputs = v}
      }

      out = err = script = nil
      begin
        script = Tempfile.new(['parser_script', '.rb'], encoding: 'UTF-8')
        script.write "
          pages << {'url' => 'https://yyy.com'}
          save_pages [{'url' => 'https://zzz.com'}]
          outputs << {'bbb' => 222}
          save_outputs [{'ccc' => 333}]
          mock_set_find_output.call find_output
          mock_set_find_outputs.call find_outputs
        "
        script.flush
        script.close

        @executor.execute_script script.path, vars
      ensure
        script.unlink unless script.nil?
      end

      assert_operator @executor.pages.count, :==, 0
      assert_operator @executor.outputs.count, :==, 0
      assert_operator @executor.saved_pages.count, :==, 2
      assert_equal 'https://zzz.com', @executor.saved_pages[0]['url']
      assert_equal 'https://yyy.com', @executor.saved_pages[1]['url']
      assert_operator @executor.saved_outputs.count, :==, 2
      assert_equal 333, @executor.saved_outputs[0]['ccc']
      assert_equal 222, @executor.saved_outputs[1]['bbb']
      assert_equal 333, expected_find_output['ccc']
      assert_operator expected_find_outputs.count, :==, 1
      assert_equal 333, expected_find_outputs[0]['ccc']
    end
  end
end
