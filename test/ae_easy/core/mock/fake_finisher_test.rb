require 'test_helper'

describe 'fake finisher' do
  before do
    @executor = AeEasy::Core::Mock::FakeFinisher.new
  end

  describe 'unit test' do
    it 'should expose methods' do
      data = verbose = nil
      begin
        verbose = $VERBOSE
        $VERBOSE = true
        out, err = capture_io do
          data = AeEasy::Core::Mock::FakeFinisher.exposed_methods
        end
        $VERBOSE = verbose
      ensure
        $VERBOSE = verbose unless verbose.nil?
      end
      expected = [
        :outputs,
        :save_outputs,
        :find_output,
        :find_outputs,
        :job_id
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
      assert_operator @executor.saved_outputs.count, :==, 2
      assert_equal 333, @executor.saved_outputs[0]['ccc']
      assert_equal 222, @executor.saved_outputs[1]['bbb']
      assert_equal 333, expected_find_output['ccc']
      assert_equal 333, expected_find_output['ccc']
      assert_operator expected_find_outputs.count, :==, 1
      assert_equal 333, expected_find_outputs[0]['ccc']
    end

    it 'should execute script with context and provide job_id' do
      out = err = script = nil
      @executor.job_id  = 789
      begin
        script = Tempfile.new(['parser_script', '.rb'], encoding: 'UTF-8')
        script.write "
          outputs << {'provided_job_id' => job_id}
        "
        script.flush
        script.close

        @executor.execute_script script.path
      ensure
        script.unlink unless script.nil?
      end

      assert_operator @executor.outputs.count, :==, 0
      assert_operator @executor.saved_outputs.count, :==, 1
      assert_equal 789, @executor.saved_outputs[0]['provided_job_id']
    end
  end
end
