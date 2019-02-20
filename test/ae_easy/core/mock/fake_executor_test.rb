require 'test_helper'

describe 'fake executor' do
  before do
    object = Object.new
    class << object
      include AeEasy::Core::Mock::FakeExecutor

      define_method :mock_initialize, lambda{|*args| initialize *args}
    end
    @executor = object
  end

  describe 'unit test' do
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

    it 'should clean array on save_pages' do
      list = [
        {'url' => 'https://aaa.com'},
        {'url' => 'https://bbb.com'},
        {'url' => 'https://ccc.com'}
      ]
      @executor.save_pages list
      assert_empty list
      assert_equal 'https://aaa.com', @executor.saved_pages[0]['url']
      assert_equal 'https://bbb.com', @executor.saved_pages[1]['url']
      assert_equal 'https://ccc.com', @executor.saved_pages[2]['url']
    end

    it 'should clean array on save_outputs' do
      list = [
        {'aaa' => 111},
        {'bbb' => '222'},
        {'ccc' => 'CCC'}
      ]
      @executor.save_outputs list
      assert_empty list
      assert_equal 111, @executor.saved_outputs[0]['aaa']
      assert_equal '222', @executor.saved_outputs[1]['bbb']
      assert_equal 'CCC', @executor.saved_outputs[2]['ccc']
    end

    it 'should clean only outputs drafts and keep saved outputs intact' do
      @executor.outputs << {'aaa' => 'AAA'}
      assert_operator @executor.outputs.count, :==, 1
      assert_empty @executor.saved_outputs
      @executor.save_outputs [{'bbb' => 'BBB'}]
      assert_operator @executor.saved_outputs.count, :==, 1
      @executor.clear_draft_outputs
      assert_empty @executor.outputs
      assert_operator @executor.saved_outputs.count, :==, 1
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

    it 'should clean only pages drafts and keep saved pages intact' do
      @executor.pages << {'url' => 'https://aaa.com'}
      assert_operator @executor.pages.count, :==, 1
      assert_empty @executor.saved_pages
      @executor.save_pages [{'url' => 'https://bbb.com'}]
      assert_operator @executor.saved_pages.count, :==, 1
      @executor.clear_draft_pages
      assert_empty @executor.pages
      assert_operator @executor.saved_pages.count, :==, 1
    end

    it 'should initialize fake db' do
      @executor.mock_initialize
      assert_kind_of AeEasy::Core::Mock::FakeDb, @executor.db
    end

    it 'should initialize with initial pages' do
      pages = [
        {'url' => 'https://aaa.com'},
        {'url' => 'https://bbb.com'}
      ]
      @executor.mock_initialize pages: pages
      expected = [
        {'url' => 'https://aaa.com'},
        {'url' => 'https://bbb.com'}
      ]
      assert_equal expected, @executor.pages
    end

    it 'should initialize with initial outputs' do
      outputs = [
        {'aaa' => 'AAA'},
        {'bbb' => 'BBB'}
      ]
      @executor.mock_initialize outputs: outputs
      expected = [
        {'aaa' => 'AAA'},
        {'bbb' => 'BBB'}
      ]
      assert_equal expected, @executor.outputs
    end

    it 'should initialize with job_id' do
      @executor.mock_initialize job_id: 123
      assert_equal 123, @executor.job_id
    end

    it 'should initialize with scraper_name' do
      @executor.mock_initialize scraper_name: 'AAA'
      assert_equal 'AAA', @executor.scraper_name
    end

    it 'should initialize with page' do
      page = {
        'gid' => 'CCC',
        'url' => 'https://ccc.com',
        'job_id' => 888
      }
      @executor.db.enable_job_id_override
      @executor.mock_initialize page: page
      assert_equal 'CCC', @executor.page['gid']
      assert_equal 'https://ccc.com', @executor.page['url']
      assert_equal 888, @executor.page['job_id']
    end

    it 'should raise error when pages has invalid type' do
      assert_raises(ArgumentError) do
        @executor.mock_initialize pages: {}
      end
    end

    it 'should raise error when outputs has invalid type' do
      assert_raises(ArgumentError) do
        @executor.mock_initialize outputs: {}
      end
    end

    it 'should set scraper name' do
      @executor.scraper_name = 'BBB'
      assert_equal 'BBB', @executor.scraper_name
    end

    it 'should set job id' do
      @executor.job_id = 444
      assert_equal 444, @executor.job_id
    end

    it 'should set page' do
      @executor.db.enable_job_id_override
      @executor.page = {
        'gid' => '111',
        'url' => 'https://aaa.com',
        'job_id' => 222
      }
      assert_equal '111', @executor.page['gid']
      assert_equal 'https://aaa.com', @executor.page['url']
      assert_equal 222, @executor.page['job_id']
    end

    it 'should save jobs to fake db correctly' do
      assert_operator @executor.saved_jobs.count, :==, 1
      assert_operator @executor.db.jobs.count, :==, 1
      @executor.save_jobs [
        {'job_id' => 111},
        {'job_id' => 222}
      ]
      assert_operator @executor.saved_jobs.count, :==, 3
      assert_operator @executor.db.jobs.count, :==, 3
      assert_equal @executor.db.jobs[1], @executor.saved_jobs[1]
      job_a = @executor.db.jobs[1]
      assert_equal 111, job_a['job_id']
      assert_equal @executor.db.jobs[2], @executor.saved_jobs[2]
      job_b = @executor.db.jobs[2]
      assert_equal 222, job_b['job_id']
    end

    it 'should save pages to fake db correctly' do
      assert_empty @executor.pages
      assert_empty @executor.db.pages
      @executor.save_pages [
        {'url' => 'https://ddd.com'},
        {'url' => 'https://eee.com'}
      ]
      assert_empty @executor.pages
      assert_operator @executor.db.pages.count, :==, 2
      page_a = @executor.db.pages[0]
      assert_equal 'https://ddd.com', page_a['url']
      page_b = @executor.db.pages[1]
      assert_equal 'https://eee.com', page_b['url']
    end

    it 'should save outputs to fake db correctly' do
      assert_empty @executor.outputs
      assert_empty @executor.db.outputs
      @executor.save_outputs [
        {'ccc' => 'CCC'},
        {'eee' => 'EEE'}
      ]
      assert_empty @executor.outputs
      output_a = @executor.db.outputs[0]
      assert_equal 'CCC', output_a['ccc']
      output_b = @executor.db.outputs[1]
      assert_equal 'EEE', output_b['eee']
    end

    it 'should raise error on check compatibility when uncompatible fragment' do
      assert_raises(AeEasy::Core::Exception::OutdatedError) do
        source = [:pages, :outputs]
        fragment = [:pages, :outputs, :save_pages]
        AeEasy::Core::Mock::FakeExecutor.check_compatibility source, fragment
      end
    end

    it 'should warn on check compatibility when non exact compatible fragment' do
      source = [:pages, :outputs, :save_outputs]
      fragment = [:pages, :outputs]
      data = nil
      verbose = nil
      begin
        verbose = $VERBOSE
        $VERBOSE = true
        out, err = capture_io do
          data = AeEasy::Core::Mock::FakeExecutor.check_compatibility source, fragment
        end
        $VERBOSE = verbose
      ensure
        $VERBOSE = verbose unless verbose.nil?
      end
      expected = {
        missing: [],
        new: [:save_outputs],
        is_compatible: true
      }
      assert_match /new\s+methods/i, err
      assert_match /save_outputs/, err
      assert_equal expected, data
    end

    it 'should check compatibility when equal' do
      source = [:pages, :outputs]
      fragment = [:pages, :outputs]
      data = nil
      verbose = nil
      begin
        verbose = $VERBOSE
        $VERBOSE = true
        out, err = capture_io do
          data = AeEasy::Core::Mock::FakeExecutor.check_compatibility source, fragment
        end
        $VERBOSE = verbose
      ensure
        $VERBOSE = verbose unless verbose.nil?
      end
      expected = {
        missing: [],
        new: [],
        is_compatible: true
      }
      assert_empty out
      assert_empty err
      assert_equal expected, data
    end

    it 'should execute script correctly' do
      class << @executor
        define_method :exposed_methods, lambda{[]}
      end
      vars = {
        aaa: 'AAA',
        bbb: 'BBB'
      }
      out = err = script = nil
      begin
        script = Tempfile.new(['parser_script', '.rb'], encoding: 'UTF-8')
        script.write "
          puts \"Hello World! \#{aaa} \#{bbb}\"
        "
        script.flush
        script.close

        verbose = nil
        begin
          verbose = $VERBOSE
          $VERBOSE = true
          out, err = capture_io do
            @executor.execute_script script.path, vars
          end
          $VERBOSE = verbose
        ensure
          $VERBOSE = verbose unless verbose.nil?
        end
      ensure
        script.unlink unless script.nil?
      end
      assert_match /Hello World! AAA BBB/, out
    end

    describe 'get latest job' do
      it 'by scraper name get null when scraper name is null' do
        @executor.save_jobs [
          {'job_id' => 111, 'scraper_name' => 'AAA'},
          {'job_id' => 222, 'scraper_name' => 'BBB'},
          {'job_id' => 333, 'scraper_name' => 'AAA'},
          {'job_id' => 444, 'scraper_name' => 'CCC'}
        ]
        data = @executor.latest_job_by nil
        assert_nil data
      end

      it 'by scraper name without filters' do
        @executor.save_jobs [
          {'job_id' => 111, 'scraper_name' => 'AAA'},
          {'job_id' => 222, 'scraper_name' => 'BBB'},
          {'job_id' => 333, 'scraper_name' => 'AAA'},
          {'job_id' => 444, 'scraper_name' => 'CCC'}
        ]
        data = @executor.latest_job_by 'AAA'
        assert_equal 333, data['job_id']
      end

      it 'by scraper name and status' do
        @executor.save_jobs [
          {'job_id' => 111, 'scraper_name' => 'AAA', 'status' => 'done'},
          {'job_id' => 222, 'scraper_name' => 'AAA', 'status' => 'done'},
          {'job_id' => 333, 'scraper_name' => 'BBB', 'status' => 'done'},
          {'job_id' => 444, 'scraper_name' => 'AAA', 'status' => 'active'}
        ]
        data = @executor.latest_job_by 'AAA', {
          'status' => 'done'
        }
        assert_equal 222, data['job_id']
      end
    end
  end

  describe 'integration test' do
    it 'should keep page in sync with db' do
      @executor.db.enable_job_id_override
      @executor.page = {
        'gid' => 'AAA',
        'job_id' => 111,
        'url' => 'https://aaa.com'
      }
      assert_equal 'AAA', @executor.page['gid']
      assert_equal 111, @executor.page['job_id']
      assert_equal 'https://aaa.com', @executor.page['url']
      assert_equal 111, @executor.job_id
      assert_equal 'AAA', @executor.db.page_gid
      @executor.page = {
        'gid' => 'BBB',
        'job_id' => 222,
        'url' => 'https://bbb.com',
        'vars' => {}
      }
      expected_b = {
        'gid' => 'BBB',
        'job_id' => 222,
        'url' => 'https://bbb.com',
        'vars' => {}
      }
      assert_equal 'BBB', @executor.page['gid']
      assert_equal 222, @executor.page['job_id']
      assert_equal 'https://bbb.com', @executor.page['url']
      assert_equal 222, @executor.job_id
      assert_equal 'BBB', @executor.db.page_gid
    end

    it 'should keep scraper name in sync with db' do
      @executor.scraper_name = 'AAA'
      assert_operator @executor.saved_jobs.count, :==, 1
      assert_equal 'AAA', @executor.scraper_name
      assert_equal 'AAA', @executor.db.scraper_name
      assert_equal 'AAA', @executor.saved_jobs.first['scraper_name']
      @executor.scraper_name = 'BBB'
      assert_equal 'BBB', @executor.scraper_name
      assert_equal 'BBB', @executor.db.scraper_name
      assert_equal 'BBB', @executor.saved_jobs.first['scraper_name']
    end

    it 'should keep job id in sync with db' do
      @executor.job_id = 444
      assert_equal 444, @executor.job_id
      assert_equal 444, @executor.page['job_id']
      assert_equal 444, @executor.db.job_id
      @executor.job_id = 222
      assert_equal 222, @executor.job_id
      assert_equal 222, @executor.page['job_id']
      assert_equal 222, @executor.db.job_id
    end

    it 'should save pages correctly' do
      assert_empty @executor.pages
      assert_empty @executor.saved_pages
      @executor.save_pages [
        {'url' => 'https://ddd.com'},
        {'url' => 'https://eee.com'}
      ]
      assert_empty @executor.pages
      assert_operator @executor.saved_pages.count, :==, 2
      page_a = @executor.saved_pages[0]
      assert_equal 'https://ddd.com', page_a['url']
      page_b = @executor.saved_pages[1]
      assert_equal 'https://eee.com', page_b['url']
    end

    it 'should save outputs correctly' do
      assert_empty @executor.outputs
      assert_empty @executor.saved_outputs
      @executor.save_outputs [
        {'ccc' => 'CCC'},
        {'eee' => 'EEE'}
      ]
      assert_empty @executor.outputs
      output_a = @executor.saved_outputs[0]
      assert_equal 'CCC', output_a['ccc']
      output_b = @executor.saved_outputs[1]
      assert_equal 'EEE', output_b['eee']
    end

    it 'should flush pages correctly' do
      assert_empty @executor.pages
      assert_empty @executor.saved_pages
      @executor.pages << {'url' => 'https://fff.com'}
      @executor.pages << {'url' => 'https://ggg.com'}
      assert_operator @executor.pages.count, :==, 2
      @executor.flush_pages
      assert_empty @executor.pages
      assert_operator @executor.saved_pages.count, :==, 2
      page_a = @executor.saved_pages[0]
      assert_equal 'https://fff.com', page_a['url']
      page_b = @executor.saved_pages[1]
      assert_equal 'https://ggg.com', page_b['url']
    end

    it 'should flush outputs correctly' do
      assert_empty @executor.outputs
      assert_empty @executor.saved_outputs
      @executor.outputs << {'fff' => 'FFF'}
      @executor.outputs << {'ggg' => 'GGG'}
      assert_operator @executor.outputs.count, :==, 2
      @executor.flush_outputs
      assert_empty @executor.outputs
      output_a = @executor.saved_outputs[0]
      assert_equal 'FFF', output_a['fff']
      output_b = @executor.saved_outputs[1]
      assert_equal 'GGG', output_b['ggg']
    end

    it 'should flush both pages and outputs' do
      assert_empty @executor.pages
      assert_empty @executor.outputs
      assert_empty @executor.saved_pages
      assert_empty @executor.saved_outputs
      @executor.pages << {'url' => 'https://hhh.com'}
      @executor.outputs << {'hhh' => '111'}
      @executor.flush
      assert_empty @executor.pages
      assert_empty @executor.outputs
      assert_operator @executor.saved_pages.count, :==, 1
      assert_operator @executor.saved_outputs.count, :==, 1
      assert_equal 'https://hhh.com', @executor.saved_pages.first['url']
      assert_equal '111', @executor.saved_outputs.first['hhh']
    end

    it 'should find an output' do
      @executor.save_outputs [
        {'aaa' => '1', 'ddd' => 'DDD'},
        {'aaa' => '2', 'eee' => 555},
        {'aaa' => '3', 'ggg' => 777},
        {'aaa' => '4', 'hhh' => 888}
      ]
      output_a = @executor.find_output 'default', {'aaa' => '1'}
      output_b = @executor.find_output 'default', {'aaa' => '3'}
      assert_equal '1', output_a['aaa']
      assert_equal 'DDD', output_a['ddd']
      assert_equal '3', output_b['aaa']
      assert_equal 777, output_b['ggg']
    end

    it 'should find outputs' do
      @executor.save_outputs [
        {'aaa' => '1', 'ddd' => 'DDD'},
        {'aaa' => '2', 'eee' => 555},
        {'aaa' => '3', 'ggg' => 777},
        {'aaa' => '2', 'hhh' => '888'}
      ]
      outputs = @executor.find_outputs 'default', {'aaa' => '2'}
      assert_operator outputs.count, :==, 2
      output_a = outputs[0]
      output_b = outputs[1]
      assert_equal '2', output_a['aaa']
      assert_equal 555, output_a['eee']
      assert_equal '2', output_b['aaa']
      assert_equal '888', output_b['hhh']
    end

    it 'should validate collection to be String when find outputs' do
      @executor.save_outputs [{'aaa' => '1'}]
      assert_raises(ArgumentError, /collection.+?String/) do
        data = @executor.find_outputs 123
      end
      data = @executor.find_outputs 'default'
      assert_operator data.count, :==, 1
      assert_equal '1', data[0]['aaa']
    end

    it 'should validate query to be Hash when find outputs' do
      @executor.save_outputs [{'aaa' => '1'}]
      assert_raises(ArgumentError, /query.+?Hash/) do
        data = @executor.find_outputs 'default', []
      end
      data = @executor.find_outputs 'default', {}
      assert_operator data.count, :==, 1
      assert_equal '1', data[0]['aaa']
    end

    it 'should validate page to be Integer when find outputs' do
      @executor.save_outputs [{'aaa' => '1'}]
      assert_raises(ArgumentError, /page.+?Integer/) do
        data = @executor.find_outputs 'default', {}, 'A'
      end
      data = @executor.find_outputs 'default', {}, 1
      assert_operator data.count, :==, 1
      assert_equal '1', data[0]['aaa']
    end

    it 'should validate page to be greater than 0 when find outputs' do
      @executor.save_outputs [{'aaa' => '1'}]
      assert_raises(ArgumentError, /page.+?greater\s+than\s+0/) do
        data = @executor.find_outputs 'default', {}, 0
      end
      data = @executor.find_outputs 'default', {}, 1
      assert_operator data.count, :==, 1
      assert_equal '1', data[0]['aaa']
    end

    it 'should validate per_page to be Integer when find outputs' do
      @executor.save_outputs [{'aaa' => '1'}]
      assert_raises(ArgumentError, /per_page.+?Integer/) do
        data = @executor.find_outputs 'default', {}, 1, 'A'
      end
      data = @executor.find_outputs 'default', {}, 1, 1
      assert_operator data.count, :==, 1
      assert_equal '1', data[0]['aaa']
    end

    it 'should validate page to be between 1 and 500 when find outputs' do
      @executor.save_outputs [{'aaa' => '1'}]
      assert_raises(ArgumentError, /per_page.+?between\s+1\s+and\s+500/) do
        data_a = @executor.find_outputs 'default', {}, 1, 0
      end
      data_a = @executor.find_outputs 'default', {}, 1, 1
      assert_operator data_a.count, :==, 1
      assert_equal '1', data_a[0]['aaa']
      assert_raises(ArgumentError, /per_page.+?between\s+1\s+and\s+500/) do
        data_b = @executor.find_outputs 'default', {}, 1, 501
      end
      data_b = @executor.find_outputs 'default', {}, 1, 500
      assert_operator data_b.count, :==, 1
      assert_equal '1', data_b[0]['aaa']
    end

    it 'should find outputs by scraper_name' do
      @executor.db.enable_job_id_override
      @executor.save_jobs [
        {'job_id' => 111, 'scraper_name' => 'AAA'},
        {'job_id' => 222, 'scraper_name' => 'BBB'}
      ]
      assert_operator @executor.saved_jobs.count, :==, 3
      @executor.save_outputs [
        {'_job_id' => 111, 'aaa' => '1'},
        {'_job_id' => 222, 'aaa' => '2'},
        {'_job_id' => 111, 'aaa' => '3'},
        {'_job_id' => 222, 'aaa' => '4'}
      ]
      assert_operator @executor.saved_outputs.count, :==, 4
      data = @executor.find_outputs 'default', {}, 1, 4, scraper_name: 'BBB'
      assert_operator data.count, :==, 2
      assert_equal '2', data[0]['aaa']
      assert_equal '4', data[1]['aaa']
    end

    it 'should find outputs by job_id' do
      @executor.db.enable_job_id_override
      @executor.save_jobs [
        {'job_id' => 111, 'scraper_name' => 'AAA'},
        {'job_id' => 222, 'scraper_name' => 'BBB'}
      ]
      assert_operator @executor.saved_jobs.count, :==, 3
      @executor.save_outputs [
        {'_job_id' => 111, 'aaa' => '1'},
        {'_job_id' => 222, 'aaa' => '2'},
        {'_job_id' => 111, 'aaa' => '3'},
        {'_job_id' => 222, 'aaa' => '4'}
      ]
      assert_operator @executor.saved_outputs.count, :==, 4
      data = @executor.find_outputs 'default', {}, 1, 4, job_id: 111
      assert_operator data.count, :==, 2
      assert_equal '1', data[0]['aaa']
      assert_equal '3', data[1]['aaa']
    end

    it 'should execute script with context and flush correctly' do
      class << @executor
        define_method(:exposed_methods) do
          [
            :content,
            :failed_content,
            :page,
            :pages,
            :outputs,
            :save_pages,
            :save_outputs,
            :find_output,
            :find_outputs,
            :mock_set_content,
            :mock_set_failed_content,
            :mock_set_page,
            :mock_set_find_output,
            :mock_set_find_outputs
          ]
        end
        define_method :mock_content, lambda{@mock_content}
        define_method :mock_set_content, lambda{|v|@mock_content = v}
        define_method :mock_failed_content, lambda{@mock_failed_content}
        define_method :mock_set_failed_content, lambda{|v|@mock_failed_content = v}
        define_method :mock_page, lambda{@mock_page}
        define_method :mock_set_page, lambda{|v|@mock_page = v}
        define_method :mock_find_output, lambda{@mock_find_output}
        define_method :mock_set_find_output, lambda{|v|@mock_find_output = v}
        define_method :mock_find_outputs, lambda{@mock_find_outputs}
        define_method :mock_set_find_outputs, lambda{|v|@mock_find_outputs = v}
      end
      @executor.db.enable_job_id_override
      @executor.page = {
        'gid' => '123',
        'job_id' => 555,
        'url' => 'https://uuu.com'
      }
      @executor.content = 'Hello content!'
      @executor.failed_content = 'Hello failed content!'

      out = err = script = nil
      begin
        script = Tempfile.new(['parser_script', '.rb'], encoding: 'UTF-8')
        script.write "
          pages << {'url' => 'https://yyy.com'}
          save_pages [{'url' => 'https://zzz.com'}]
          outputs << {'bbb' => 222}
          save_outputs [{'ccc' => 333},{'ddd': '444'}]
          mock_set_page page
          mock_set_content content
          mock_set_failed_content failed_content
          mock_set_find_output find_output
          mock_set_find_outputs find_outputs
        "
        script.flush
        script.close

        @executor.execute_script script.path
      ensure
        script.unlink unless script.nil?
      end

      assert_equal 'Hello content!', @executor.mock_content
      assert_equal 'Hello failed content!', @executor.mock_failed_content
      assert_equal '123', @executor.mock_page['gid']
      assert_equal 555, @executor.mock_page['job_id']
      assert_equal 'https://uuu.com', @executor.mock_page['url']
      assert_operator @executor.pages.count, :==, 0
      assert_operator @executor.outputs.count, :==, 0
      assert_operator @executor.saved_pages.count, :==, 2
      assert_equal 'https://zzz.com', @executor.saved_pages[0]['url']
      assert_equal 'https://yyy.com', @executor.saved_pages[1]['url']
      assert_operator @executor.saved_outputs.count, :==, 3
      assert_equal 333, @executor.saved_outputs[0]['ccc']
      assert_equal '444', @executor.saved_outputs[1]['ddd']
      assert_equal 222, @executor.saved_outputs[2]['bbb']
      assert_equal 333, @executor.mock_find_output['ccc']
      assert_operator @executor.mock_find_outputs.count, :==, 2
      assert_equal 333, @executor.mock_find_outputs[0]['ccc']
      assert_equal '444', @executor.mock_find_outputs[1]['ddd']
    end
  end
end
