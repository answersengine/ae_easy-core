require 'test_helper'

describe 'fake db' do
  describe 'unit test' do
    it 'should have page keys' do
      expected = ['gid']
      assert_equal expected.sort, AeEasy::Core::Mock::FakeDb::PAGE_KEYS.sort
    end

    it 'should have output keys' do
      expected = ['_id', '_collection']
      assert_equal expected.sort, AeEasy::Core::Mock::FakeDb::OUTPUT_KEYS.sort
    end

    it 'should have job keys' do
      expected = ['job_id']
      assert_equal expected.sort, AeEasy::Core::Mock::FakeDb::JOB_KEYS.sort
    end

    it 'should have job statuses' do
      expected = {
        active: 'active',
        done: 'done',
        cancelled: 'cancelled',
        paused: 'paused'
      }
      assert_equal expected, AeEasy::Core::Mock::FakeDb::JOB_STATUSES
    end

    it 'should have default collection' do
      expected = 'default'
      assert_equal expected, AeEasy::Core::Mock::FakeDb::DEFAULT_COLLECTION
    end

    it 'should create new smart collection' do
      data = AeEasy::Core::Mock::FakeDb.new_collection []
      assert_kind_of AeEasy::Core::SmartCollection, data
    end

    it 'should create random fake uuid as string when no seed' do
      uuid_a = AeEasy::Core::Mock::FakeDb.fake_uuid
      uuid_b = AeEasy::Core::Mock::FakeDb.fake_uuid
      refute_equal uuid_a, uuid_b
      assert_kind_of String, uuid_a
      assert_kind_of String, uuid_b
      assert_operator uuid_a.length, :>, 0
      assert_operator uuid_b.length, :>, 0
    end

    it 'should create fake uuid as string when seed' do
      uuid = AeEasy::Core::Mock::FakeDb.fake_uuid 'abc'
      assert_kind_of String, uuid
      assert_operator uuid.length, :>, 0
    end

    it 'should create consistent uniq fake uuid when seed' do
      uuid_a = AeEasy::Core::Mock::FakeDb.fake_uuid 'a'
      uuid_b = AeEasy::Core::Mock::FakeDb.fake_uuid 'b'
      refute_equal uuid_a, uuid_b

      second_uuid_a = AeEasy::Core::Mock::FakeDb.fake_uuid 'a'
      second_uuid_b = AeEasy::Core::Mock::FakeDb.fake_uuid 'b'
      assert_equal second_uuid_a, uuid_a
      assert_equal second_uuid_b, uuid_b
    end

    it 'should create consistent uniq fake uuid when object seed' do
      uuid_a = AeEasy::Core::Mock::FakeDb.fake_uuid({'aaa' => 111})
      uuid_b = AeEasy::Core::Mock::FakeDb.fake_uuid({'bbb' => 222})
      refute_equal uuid_a, uuid_b

      second_uuid_a = AeEasy::Core::Mock::FakeDb.fake_uuid({'aaa' => 111})
      second_uuid_b = AeEasy::Core::Mock::FakeDb.fake_uuid({'bbb' => 222})
      assert_equal second_uuid_a, uuid_a
      assert_equal second_uuid_b, uuid_b
    end

    describe 'clean_uri' do
      it 'should clean fragment from url' do
        url = 'https://abc.com/aaa/bbb?ccc=333#I-am-a-fragment'
        data = AeEasy::Core::Mock::FakeDb.clean_uri url
        expected = 'https://abc.com/aaa/bbb?ccc=333'
        assert_equal expected, data
      end

      it 'should lowercase schema and hostname' do
        url = 'htTps://wwW.aBc.com/aAa/bbB?cCc=333'
        data = AeEasy::Core::Mock::FakeDb.clean_uri url
        expected = 'https://www.abc.com/aAa/bbB?cCc=333'
        assert_equal expected, data
      end

      it 'should sort query string' do
        url = 'https://www.abc.com/aaa/bbb?ddd=ddd&eee=eee&ccc=333&ddd=444&eee=555'
        data = AeEasy::Core::Mock::FakeDb.clean_uri url
        expected = 'https://www.abc.com/aaa/bbb?ccc=333&ddd=ddd&ddd=444&eee=eee&eee=555'
        assert_equal expected, data
      end

      it 'should clean without query string' do
        url = 'https://abc.com/aaa/bbb'
        data = AeEasy::Core::Mock::FakeDb.clean_uri url
        expected = 'https://abc.com/aaa/bbb'
        assert_equal expected, data
      end
    end

    it 'should initialize without options' do
      db = AeEasy::Core::Mock::FakeDb.new
      assert_kind_of AeEasy::Core::Mock::FakeDb, db
    end

    it 'should initialize with job_id' do
      db = AeEasy::Core::Mock::FakeDb.new job_id: 123
      expected = 123
      assert_kind_of AeEasy::Core::Mock::FakeDb, db
      assert_equal expected, db.job_id
    end

    it 'should initialize with page_gid' do
      db = AeEasy::Core::Mock::FakeDb.new page_gid: '123'
      expected = '123'
      assert_kind_of AeEasy::Core::Mock::FakeDb, db
      assert_equal expected, db.page_gid
    end

    it 'should initialize with enabled allow_page_gid_override' do
      db = AeEasy::Core::Mock::FakeDb.new allow_page_gid_override: true
      assert_kind_of AeEasy::Core::Mock::FakeDb, db
      assert db.allow_page_gid_override?
    end

    it 'should initialize with disabled allow_page_gid_override' do
      db = AeEasy::Core::Mock::FakeDb.new allow_page_gid_override: false
      assert_kind_of AeEasy::Core::Mock::FakeDb, db
      refute db.allow_page_gid_override?
    end

    it 'should initialize with enabled allow_job_id_override' do
      db = AeEasy::Core::Mock::FakeDb.new allow_job_id_override: true
      assert_kind_of AeEasy::Core::Mock::FakeDb, db
      assert db.allow_job_id_override?
    end

    it 'should initialize with disabled allow_job_id_override' do
      db = AeEasy::Core::Mock::FakeDb.new allow_job_id_override: false
      assert_kind_of AeEasy::Core::Mock::FakeDb, db
      refute db.allow_job_id_override?
    end

    it 'should generate time stamp correctly' do
      time = Time.new 2019, 9, 10, 20, 15, 1
      assert_equal '2019-09-10T20:15:01Z', AeEasy::Core::Mock::FakeDb.time_stamp(time)
    end

    describe 'instance' do
      before do
        @db = AeEasy::Core::Mock::FakeDb.new
      end

      it 'should set job id' do
        @db.job_id = 222
        assert_equal 222, @db.job_id
      end

      it 'should set page gid' do
        @db.page_gid = '333'
        assert_equal '333', @db.page_gid
      end

      it 'should enable allow_page_gid_override' do
        @db.enable_page_gid_override
        assert @db.allow_page_gid_override?
      end

      it 'should disable allow_page_gid_override' do
        @db.disable_page_gid_override
        refute @db.allow_page_gid_override?
      end

      it 'should generate same page gid when fragment' do
        gid_a = @db.generate_page_gid('url' => 'https://abc.com/aaa#fragment')
        gid_b = @db.generate_page_gid('url' => 'https://abc.com/aaa')
        assert_equal gid_a, gid_b
      end

      it 'should generate same page gid when unsorted query string' do
        gid_a = @db.generate_page_gid('url' => 'https://abc.com/aaa/?aaa=111&bbb=222')
        gid_b = @db.generate_page_gid('url' => 'https://abc.com/aaa/?bbb=222&aaa=111')
        assert_equal gid_a, gid_b
      end

      it 'should generate same page gid when schema and hostname differ on case' do
        gid_a = @db.generate_page_gid('url' => 'htTps://aBc.com/aaa')
        gid_b = @db.generate_page_gid('url' => 'HttPs://abC.cOm/aaa')
        assert_equal gid_a, gid_b
      end

      it 'should generate same page gid when headers contains an unsorted array' do
        headers_a = {
          'aaa' => ['bbb', 'ccc', 'ddd'],
          'bbb' => 222,
          'ccc' => 'ccc'
        }
        gid_a = @db.generate_page_gid('url' => 'https://abc.com', 'headers' => headers_a)
        headers_b = {
          'aaa' => ['ccc', 'bbb', 'ddd'],
          'bbb' => 222,
          'ccc' => 'ccc'
        }
        gid_b = @db.generate_page_gid('url' => 'https://abc.com', 'headers' => headers_b)
        assert_equal gid_a, gid_b
      end

      it 'should generate same page gid when headers contains an unsorted array' do
        cookie_a = 'aaa=111; bbb=222; ccc=ccc'
        gid_a = @db.generate_page_gid('url' => 'https://www.abc.com', 'cookie' => cookie_a)
        cookie_b = 'ccc=ccc; aaa=111; bbb=222'
        gid_b = @db.generate_page_gid('url' => 'https://www.abc.com', 'cookie' => cookie_b)
        assert_equal gid_a, gid_b
      end

      it 'should generate page gids consistently' do
        base_hash = {
          'url' => 'https://aaa.com',
          'method' => 'GET',
          'headers' => {
            'Cookies' => 0,
            'Referer' => 0
          },
          'fetch_type' => 0,
          'cookie' => 'aaa=111',
          'no_redirect' => [],
          'body' => 0,
          'ua_type' => 0
        }
        hash = gid_a = gid_b = nil
        gid_list = []
        keys = base_hash.keys
        keys.each do |key|
          hash = base_hash.clone
          if hash[key].is_a? Hash
            hash[key] = base_hash[key].clone
            hash[key][hash.keys.first] = 111
          elsif hash[key].is_a? Array
            hash[key] = base_hash[key].clone
            hash[key].pop
          elsif hash[key].is_a? Integer
            hash[key] = 111
          elsif key == 'url'
            hash[key] = 'https://bbb.com'
          elsif key == 'cookie'
            hash[key] = 'bbb=222'
          else
            hash[key] = '222'
          end
          gid_a = @db.generate_page_gid hash
          gid_b = @db.generate_page_gid hash

          # Make sure gid is consistent
          assert_equal gid_a, gid_b
          refute_includes gid_list, gid_a
          gid_list << gid_a
        end
      end

      it 'should generate page defaults' do
        expected_keys = [
          'url',
          'job_id',
          'status',
          'method',
          'headers',
          'fetch_type',
          'cookie',
          'no_redirect',
          'body',
          'ua_type',
          'no_url_encode',
          'http2',
          'vars'
        ]
        data = @db.page_defaults
        assert_equal expected_keys.sort, data.keys.sort
        assert_nil data['url']
        assert_equal @db.job_id, data['job_id'].call({})
        assert_equal 'GET', data['method']
        assert_equal({}, data['headers'])
        assert_equal 'standard', data['fetch_type']
        assert_nil data['cookie']
        assert_equal false, data['no_redirect']
        assert_nil data['body']
        assert_equal 'desktop', data['ua_type']
        assert_equal({}, data['vars'])
      end

      it 'should generate output ids unique and random' do
        id_a = @db.generate_output_id('aaa' => 'AAA')
        id_b = @db.generate_output_id('aaa' => 'AAA')
        refute_equal id_a, id_b
        refute_empty id_a
        assert_kind_of String, id_a
        refute_empty id_b
        assert_kind_of String, id_b
      end

      it 'should generate output ids consistently' do
        base_hash = {
          'aaa' => 0,
          'bbb' => 0,
          'ccc' => 0,
          'ddd' => 0,
          'eee' => 0,
          'fff' => {
            'ggg' => 0,
            'hhh' => 0
          },
          'iii' => [1,2,3]
        }
        hash = id_a = id_b = nil
        id_list = []
        keys = base_hash.keys
        keys.each do |key|
          hash = base_hash.clone
          if hash[key].is_a? Hash
            hash[key] = base_hash[key].clone
            hash[key][hash.keys.first] = 111
          elsif hash[key].is_a? Array
            hash[key] = base_hash[key].clone
            hash[key].pop
          else
            hash[key] = 111
          end
          id_a = AeEasy::Core::Mock::FakeDb.output_uuid hash
          id_b = AeEasy::Core::Mock::FakeDb.output_uuid hash

          # Make sure id is consistent
          assert_equal id_a, id_b
          refute_includes id_list, id_a
          id_list << id_a
        end
      end

      it 'should match a hash with success filters' do
        data = {
          'aaa' => 111,
          'bbb' => 222,
          'ccc' => 'CCC',
          'ddd' => 444
        }
        filters = {
          'bbb' => 222,
          'ccc' => 'CCC'
        }
        assert @db.match?(data, filters)
      end

      it 'should match a hash with nil values and success filters' do
        data = {
          'aaa' => 111,
          'bbb' => 222,
          'ccc' => 'CCC',
          'ddd' => 444
        }
        filters = {
          'bbb' => 222,
          'ccc' => 'CCC',
          'eee' => nil
        }
        assert @db.match?(data, filters)
      end

      it 'should not match a hash with wrong filters' do
        data = {
          'aaa' => 111,
          'bbb' => 222,
          'ccc' => 'CCC',
          'ddd' => 444
        }
        filters = {
          'bbb' => 'BBB',
          'ccc' => 'CCC'
        }
        refute @db.match?(data, filters)
      end

      it 'should generate gid on page insert' do
        assert_empty @db.pages
        @db.pages << {
          'url' => 'https://www.example.com'
        }
        assert_operator @db.pages.count, :==, 1
        page = @db.pages.first
        assert_kind_of String, page['gid']
        assert_operator page['gid'].length, :>, 0
      end

      it 'should stringify page data on page insert' do
        assert_empty @db.pages
        input_page = {
          gid: '111',
          url: 'https://www.example.com/abc',
          method: 'POST',
          headers: {
            Cookie: 'abc=123'
          },
          fetch_type: 'browser',
          cookie: 'bbb=BBB',
          no_redirect: true,
          body: 'aaa=AAA',
          ua_type: 'mobile',
          no_url_encode: true,
          http2: true
        }
        @db.pages << input_page
        expected = [{
          'gid' => @db.pages.first['gid'],
          'job_id' => @db.job_id,
          'status' => 'to_fetch',
          'url' => 'https://www.example.com/abc',
          'method' => 'POST',
          'headers' => {
            'Cookie' => 'abc=123'
          },
          'fetch_type' => 'browser',
          'cookie' => 'bbb=BBB',
          'no_redirect' => true,
          'body' => 'aaa=AAA',
          'ua_type' => 'mobile',
          'no_url_encode' => true,
          'http2' => true,
          'vars' => {}
        }]
        assert_equal expected, @db.pages
      end

      it 'should not modify original page data on page insert' do
        assert_empty @db.pages
        input_page = {
          'url' => 'https://www.example.com',
          :vars => {
            aaa: 111,
            'bbb' => 222
          }
        }
        @db.pages << input_page
        expected = {
          'url' => 'https://www.example.com',
          :vars => {
            aaa: 111,
            'bbb' => 222
          }
        }
        assert_equal expected, input_page
      end

      it 'should add missing values on page insert' do
        assert_empty @db.pages
        @db.pages << {
          'url' => 'https://www.example.com/abc',
          'headers' => {
            'Cookie' => 'abc=123'
          }
        }
        expected = [{
          'gid' => @db.pages.first['gid'],
          'job_id' => @db.job_id,
          'status' => 'to_fetch',
          'url' => 'https://www.example.com/abc',
          'method' => 'GET',
          'headers' => {
            'Cookie' => 'abc=123'
          },
          'fetch_type' => 'standard',
          'cookie' => nil,
          'no_redirect' => false,
          'body' => nil,
          'ua_type' => 'desktop',
          'no_url_encode' => false,
          'http2' => false,
          'vars' => {}
        }]
        assert_operator @db.pages.count, :==, 1
        assert_equal expected, @db.pages
      end

      it 'should replace gid on page insert' do
        assert_empty @db.pages
        @db.pages << {
          'gid' => '555',
          'url' => 'https://www.example.com/abc',
          'headers' => {
            'Cookie' => 'abc=123'
          }
        }
        assert_operator @db.pages.count, :==, 1
        refute_equal '555', @db.pages.first['gid']
      end

      it 'should keep gid on page insert when page gid override is enabled' do
        @db.enable_page_gid_override
        assert_empty @db.pages
        @db.pages << {
          'gid' => '555',
          'url' => 'https://www.example.com/abc',
          'headers' => {
            'Cookie' => 'abc=123'
          }
        }
        assert_operator @db.pages.count, :==, 1
        assert_equal '555', @db.pages.first['gid']
      end

      it 'should replace page with same gid on page insert when page gid override is enabled' do
        @db.enable_page_gid_override
        assert_empty @db.pages
        @db.pages << {
          'gid' => '555',
          'url' => 'https://www.example.com/aaa'
        }
        @db.pages << {
          'gid' => '555',
          'url' => 'https://www.example.com/bbb'
        }
        expected = [{
          'gid' => '555',
          'job_id' => @db.job_id,
          'status' => 'to_fetch',
          'url' => 'https://www.example.com/bbb',
          'method' => 'GET',
          'headers' => {},
          'fetch_type' => 'standard',
          'cookie' => nil,
          'no_redirect' => false,
          'body' => nil,
          'ua_type' => 'desktop',
          'no_url_encode' => false,
          'http2' => false,
          'vars' => {}
        }]
        assert_equal expected, @db.pages
      end

      it 'should insert new page with same gid on page insert when page gid override is disabled' do
        @db.disable_page_gid_override
        assert_empty @db.pages
        @db.pages << {
          'gid' => '555',
          'url' => 'https://www.example.com/aaa'
        }
        assert_operator @db.pages.count, :==, 1
        @db.pages << {
          'gid' => '555',
          'url' => 'https://www.example.com/bbb'
        }
        assert_operator @db.pages.count, :==, 2
        refute_equal @db.pages[0]['gid'], @db.pages[1]['gid']
      end

      it 'should keep job_id on page insert when job id override is enabled' do
        @db.enable_job_id_override
        assert_empty @db.pages
        @db.job_id = 222
        @db.pages << {
          'job_id' => 111,
          'url' => 'https://www.example.com/abc'
        }
        assert_operator @db.pages.count, :==, 1
        assert_equal 111, @db.pages.first['job_id']
      end

      it 'should replace job id on page insert when job id override is disabled' do
        @db.disable_job_id_override
        assert_empty @db.pages
        @db.job_id = 222
        @db.pages << {
          'job_id' => 111,
          'url' => 'https://www.example.com/aaa'
        }
        assert_operator @db.pages.count, :==, 1
        assert_equal 222, @db.pages[0]['job_id']
      end

      it 'should keep job_id on output insert when job id override is enabled' do
        @db.enable_job_id_override
        assert_empty @db.outputs
        @db.job_id = 222
        @db.outputs << {
          '_job_id' => 111,
          'aaa' => 'AAA'
        }
        assert_operator @db.outputs.count, :==, 1
        assert_equal 111, @db.outputs.first['_job_id']
      end

      it 'should replace job id on output insert when job id override is disabled' do
        @db.disable_job_id_override
        assert_empty @db.outputs
        @db.job_id = 222
        @db.outputs << {
          '_job_id' => 111,
          'aaa' => 'AAA'
        }
        assert_operator @db.outputs.count, :==, 1
        assert_equal 222, @db.outputs[0]['_job_id']
      end

      it 'should generate id on output insert' do
        assert_empty @db.outputs
        @db.outputs << {
          'aaa' => 'AAA'
        }
        assert_operator @db.outputs.count, :==, 1
        output = @db.outputs.first
        assert_kind_of String, output['_id']
        assert_operator output['_id'].length, :>, 0
      end

      it 'should generate scraper_name on job insert' do
        assert_operator @db.jobs.count, :==, 1
        @db.jobs << {
          'job_id' => 123
        }
        assert_operator @db.jobs.count, :==, 2
        job = @db.jobs.last
        assert_kind_of String, job['scraper_name']
        assert_operator job['scraper_name'].strip.length, :>, 0
      end

      it 'should generate job_id on job insert' do
        assert_operator @db.jobs.count, :==, 1
        @db.jobs << {
          'scraper_name' => 'AAA'
        }
        assert_operator @db.jobs.count, :==, 2
        job = @db.jobs.last
        assert_kind_of Integer, job['job_id']
        assert_equal 2, job['job_id']
      end

      it 'should raise error on query when unknown collection' do
        assert_raises(ArgumentError, 'Unknown collection aaa.') do
          @db.query :aaa, {}
        end
      end

      describe 'frozen_time' do
        before do
          @time = Time.now
          @formatted_time = @time.strftime('%Y-%m-%dT%H:%M:%SZ')
          Timecop.freeze @time
          @output_base = {
            '_collection' => 'default',
            '_job_id' => @db.job_id,
            '_created_at' => @formatted_time,
            '_gid' => @db.page_gid
          }
        end

        after do
          Timecop.return
        end

        it 'should build page without options' do
          page = {
            'gid' => 'abc',
            'url' => 'https://vvv.com',
            'method' => 'POST',
            'vars' => {
              'aaa' => 'AAA'
            }
          }
          data = AeEasy::Core::Mock::FakeDb.build_page page
          expected = {
            'gid' => 'abc',
            'job_id' => @db.job_id,
            'status' => 'to_fetch',
            'url' => 'https://vvv.com',
            'method' => 'POST',
            'headers' => {},
            'fetch_type' => 'standard',
            'cookie' => nil,
            'no_redirect' => false,
            'body' => nil,
            'ua_type' => 'desktop',
            'no_url_encode' => false,
            'http2' => false,
            'vars' => {
              'aaa' => 'AAA'
            }
          }
          assert_equal expected, data
        end

        it 'should build fake page without options' do
          data = AeEasy::Core::Mock::FakeDb.build_fake_page
          expected = {
            'gid' => data['gid'],
            'job_id' => @db.job_id,
            'status' => 'to_fetch',
            'url' => 'https://example.com',
            'method' => 'GET',
            'headers' => {},
            'fetch_type' => 'standard',
            'cookie' => nil,
            'no_redirect' => false,
            'body' => nil,
            'ua_type' => 'desktop',
            'no_url_encode' => false,
            'http2' => false,
            'vars' => {}
          }
          assert_equal expected, data
        end

        it 'should build job without options' do
          job = {
            'job_id' => 123,
            'scraper_name' => 'abc'
          }
          data = AeEasy::Core::Mock::FakeDb.build_job job
          expected = {
            'job_id' => 123,
            'scraper_name' => 'abc',
            'status' => 'done',
            'created_at' => @time
          }
          assert_operator data, :==, expected
        end

        it 'should build fake job without options' do
          data = AeEasy::Core::Mock::FakeDb.build_fake_job
          expected_keys = [
            'job_id',
            'scraper_name',
            'status',
            'created_at'
          ]
          assert_equal expected_keys.sort, data.keys.sort
          assert_kind_of Integer, data['job_id']
          assert_operator data['job_id'], :>, 0
          assert_kind_of String, data['scraper_name']
          refute_equal '', data['scraper_name'].strip
          assert_equal 'done', data['status']
        end

        it 'should generate job defaults' do
          class << @db
            define_method(:generate_job_id){123}
            define_method(:generate_scraper_name){'abc'}
          end
          data = @db.job_defaults
          keys = data.keys
          expected_keys = [
            'job_id',
            'scraper_name',
            'status',
            'created_at'
          ]
          assert_equal expected_keys.sort, keys.sort
          assert_equal 123, data['job_id'].call({})
          assert_equal 'abc', data['scraper_name'].call({})
          assert_equal 'done', data['status']
          assert_equal @time, data['created_at'].call({})
        end

        it 'should stringify job data on job insert' do
          assert_operator @db.jobs.count, :==, 1
          input_job = {
            job_id: 111,
            scraper_name: 'BBB',
            status: 'cancelled'
          }
          @db.jobs << input_job
          assert_operator @db.jobs.count, :==, 2
          expected = {
            'job_id' => 111,
            'scraper_name' => 'BBB',
            'status' => 'cancelled',
            'created_at' => @time
          }
          assert_equal expected, @db.jobs.last
        end

        it 'should not modify original job data on job insert' do
          assert_operator @db.jobs.count, :==, 1
          input_job = {
            job_id: 222,
            'scraper_name': 'CCC',
            'status' => 'done'
          }
          @db.jobs << input_job
          assert_operator @db.jobs.count, :==, 2
          expected = {
            job_id: 222,
            'scraper_name': 'CCC',
            'status' => 'done'
          }
          assert_equal expected, input_job
        end

        it 'should add missing values on job insert' do
          assert_operator @db.jobs.count, :==, 1
          @db.job_id = 123
          @db.jobs << {
            'scraper_name' => 'CCC'
          }
          expected = {
            'job_id' => 124,
            'scraper_name' => 'CCC',
            'status' => 'done',
            'created_at' => @time
          }
          assert_equal expected, @db.jobs.last
        end

        it 'should replace job with same id on job insert' do
          assert_operator @db.jobs.count, :==, 1
          @db.jobs << {
            'job_id' => 444,
            'scraper_name' => 'AAA'
          }
          assert_operator @db.jobs.count, :==, 2
          @db.jobs << {
            'job_id' => 444,
            'scraper_name' => 'BBB'
          }
          assert_operator @db.jobs.count, :==, 2
          job = @db.jobs.last
          assert_equal 444, job['job_id']
          assert_equal 'BBB', job['scraper_name']
        end

        it 'should generate output defaults' do
          @db.job_id = 444
          @db.page_gid = '555'
          data = @db.output_defaults
          keys = data.keys
          expected_keys = [
            '_collection',
            '_created_at',
            '_gid',
            '_job_id'
          ]
          assert_equal expected_keys.sort, keys.sort
          assert_equal 'default', data['_collection']
          assert_equal 444, data['_job_id'].call({})
          assert_equal '555', data['_gid'].call({})
          assert_equal @formatted_time, data['_created_at'].call({})
        end

        it 'should stringify output data on output insert' do
          assert_empty @db.outputs
          input_output = {
            _id: '111',
            aaa: 222,
            bbb: {
              ccc: 444,
              ddd: {
                eee: 555
              }
            }
          }
          @db.outputs << input_output
          expected = [@output_base.merge(
            '_id' => '111',
            'aaa' => 222,
            'bbb' => {
              'ccc' => 444,
              'ddd' => {
                'eee' => 555
              }
            }
          )]
          assert_equal expected, @db.outputs
        end

        it 'should not modify original output data on output insert' do
          assert_empty @db.outputs
          input_output = {
            'aaa' => 222,
            bbb: {
              ccc: 444,
              'ddd' => {
                eee: 555
              }
            }
          }
          @db.outputs << input_output
          expected = {
            'aaa' => 222,
            bbb: {
              ccc: 444,
              'ddd' => {
                eee: 555
              }
            }
          }
          assert_equal expected, input_output
        end

        it 'should add missing values on output insert' do
          @db.job_id = 111
          @db.page_gid = '123'
          assert_empty @db.outputs
          @db.outputs << {
            '_id' => '555',
            'aaa' => 'AAA'
          }
          expected = [{
            '_collection' => 'default',
            '_job_id' => 111,
            '_gid' => '123',
            '_created_at' => @formatted_time,
            '_id' => '555',
            'aaa' => 'AAA'
          }]
          assert_equal expected, @db.outputs
        end

        it 'should replace output with same id on output insert' do
          assert_empty @db.outputs
          @db.outputs << {
            '_id' => 'AAA',
            'aaa' => 111
          }
          @db.outputs << {
            '_id' => 'AAA',
            'bbb' => 'BBB'
          }
          expected = [@output_base.merge(
            '_id' => 'AAA',
            'bbb' => 'BBB'
          )]
          assert_equal expected, @db.outputs
        end

        it 'should refetch correctly' do
          assert_empty @db.pages
          input_page = {
            gid: '111',
            url: 'https://www.example.com/abc',
            status: 'parsed',
            method: 'POST',
            headers: {
              Cookie: 'abc=123'
            },
            fetch_type: 'browser',
            cookie: 'bbb=BBB',
            no_redirect: true,
            body: 'aaa=AAA',
            ua_type: 'mobile',
            no_url_encode: true,
            http2: true,
            freshness: '2019-01-20T10:20:30Z',
            to_fetch: '2019-01-20T10:20:30Z',
            fetching_at: '2009-01-20T10:25:45Z',
            fetched_at: '2009-01-20T10:26:25Z',
            fetching_try_count: 2,
            effective_url: 'https://www.example.com/abc',
            parsing_at: '2019-01-20T10:26:50Z',
            parsing_failed_at: '2019-01-20T10:26:30Z',
            parsed_at: '2019-01-20T10:26:55Z',
            parsing_try_count: 3,
            parsing_fail_count: 2,
            parsing_updated_at: '2019-01-20T10:26:55Z',
            response_checksum: '123abc',
            response_status: '200 OK',
            response_status_code: '200',
            response_headers: {
              "Connection" => [
                "keep-alive",
                "Transfer-Encoding"
              ],
              "Content-Encoding" => [
                "gzip"
              ]
            },
            response_cookie: 'aaa=111',
            response_proto: 'HTTP/1.1',
            content_type: 'text/html; charset=UTF-8',
            content_size: 48126,
            failed_response_status_code: 500,
            failed_response_headers: {
              "Connection" => [
                "Transfer-Encoding"
              ],
              "Content-Encoding" => [
                "gzip"
              ]
            },
            failed_response_cookie: 'bbb=222',
            failed_effective_url: 'https://www.example.com/abc',
            failed_at: '2009-01-20T10:23:11Z',
            failed_content_type: 'text/html; charset=UTF-8'
          }
          @db.pages << input_page

          # Validate page before refetch
          gid = @db.pages.first['gid']
          job_id = @db.job_id
          expected_before_refetch = [{
            'gid' => gid,
            'job_id' => job_id,
            'status' => 'parsed',
            'url' => 'https://www.example.com/abc',
            'method' => 'POST',
            'headers' => {
              'Cookie' => 'abc=123'
            },
            'fetch_type' => 'browser',
            'cookie' => 'bbb=BBB',
            'no_redirect' => true,
            'body' => 'aaa=AAA',
            'ua_type' => 'mobile',
            'no_url_encode' => true,
            'http2' => true,
            'vars' => {},
            'freshness' => '2019-01-20T10:20:30Z',
            'to_fetch' => '2019-01-20T10:20:30Z',
            'fetching_at' => '2009-01-20T10:25:45Z',
            'fetched_at' => '2009-01-20T10:26:25Z',
            'fetching_try_count' => 2,
            'effective_url' => 'https://www.example.com/abc',
            'parsing_at' => '2019-01-20T10:26:50Z',
            'parsing_failed_at' => '2019-01-20T10:26:30Z',
            'parsed_at' => '2019-01-20T10:26:55Z',
            'parsing_try_count' => 3,
            'parsing_fail_count' => 2,
            'parsing_updated_at' => '2019-01-20T10:26:55Z',
            'response_checksum' => '123abc',
            'response_status' => '200 OK',
            'response_status_code' => '200',
            'response_headers' => {
              "Connection" => [
                "keep-alive",
                "Transfer-Encoding"
              ],
              "Content-Encoding" => [
                "gzip"
              ]
            },
            'response_cookie' => 'aaa=111',
            'response_proto' => 'HTTP/1.1',
            'content_type' => 'text/html; charset=UTF-8',
            'content_size' => 48126,
            'failed_response_status_code' => 500,
            'failed_response_headers' => {
              "Connection" => [
                "Transfer-Encoding"
              ],
              "Content-Encoding" => [
                "gzip"
              ]
            },
            'failed_response_cookie' => 'bbb=222',
            'failed_effective_url' => 'https://www.example.com/abc',
            'failed_at' => '2009-01-20T10:23:11Z',
            'failed_content_type' => 'text/html; charset=UTF-8'
          }]
          assert_equal expected_before_refetch, @db.pages

          # Validate page after refetch
          @db.refetch job_id, gid
          expected_after_refetch = [{
            'gid' => gid,
            'job_id' => job_id,
            'status' => 'to_fetch',
            'url' => 'https://www.example.com/abc',
            'method' => 'POST',
            'headers' => {
              'Cookie' => 'abc=123'
            },
            'fetch_type' => 'browser',
            'cookie' => 'bbb=BBB',
            'no_redirect' => true,
            'body' => 'aaa=AAA',
            'ua_type' => 'mobile',
            'no_url_encode' => true,
            'http2' => true,
            'vars' => {},

            'freshness' => @time.utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
            'to_fetch' => @time.utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
            'fetched_from' => nil,
            'fetching_at' => '2001-01-01T00:00:00Z',
            'fetched_at' => nil,
            'fetching_try_count' => 0,
            'effective_url' => nil,
            'parsing_at' => nil,
            'parsing_failed_at' => nil,
            'parsed_at' => nil,
            'parsing_try_count' => 0,
            'parsing_fail_count' => 0,
            'parsing_updated_at' => '2001-01-01T00:00:00Z',
            'response_checksum' => nil,
            'response_status' => nil,
            'response_status_code' => nil,
            'response_headers' => nil,
            'response_cookie' => nil,
            'response_proto' => nil,
            'content_type' => nil,
            'content_size' => 0,
            'failed_response_status_code' => nil,
            'failed_response_headers' => nil,
            'failed_response_cookie' => nil,
            'failed_effective_url' => nil,
            'failed_at' => nil,
            'failed_content_type' => nil,
          }]
          assert_equal expected_after_refetch, @db.pages
        end

        it 'should reparse correctly' do
          assert_empty @db.pages
          input_page = {
            gid: '111',
            url: 'https://www.example.com/abc',
            status: 'parsed',
            method: 'POST',
            headers: {
              Cookie: 'abc=123'
            },
            fetch_type: 'browser',
            cookie: 'bbb=BBB',
            no_redirect: true,
            body: 'aaa=AAA',
            ua_type: 'mobile',
            no_url_encode: true,
            http2: true,
            freshness: '2019-01-20T10:20:30Z',
            to_fetch: '2019-01-20T10:20:30Z',
            fetching_at: '2009-01-20T10:25:45Z',
            fetched_at: '2009-01-20T10:26:25Z',
            fetching_try_count: 2,
            effective_url: 'https://www.example.com/abc',
            parsing_at: '2019-01-20T10:26:50Z',
            parsing_failed_at: '2019-01-20T10:26:30Z',
            parsed_at: '2019-01-20T10:26:55Z',
            parsing_try_count: 3,
            parsing_fail_count: 2,
            parsing_updated_at: '2019-01-20T10:26:55Z',
            response_checksum: '123abc',
            response_status: '200 OK',
            response_status_code: '200',
            response_headers: {
              "Connection" => [
                "keep-alive",
                "Transfer-Encoding"
              ],
              "Content-Encoding" => [
                "gzip"
              ]
            },
            response_cookie: 'aaa=111',
            response_proto: 'HTTP/1.1',
            content_type: 'text/html; charset=UTF-8',
            content_size: 48126,
            failed_response_status_code: 500,
            failed_response_headers: {
              "Connection" => [
                "Transfer-Encoding"
              ],
              "Content-Encoding" => [
                "gzip"
              ]
            },
            failed_response_cookie: 'bbb=222',
            failed_effective_url: 'https://www.example.com/abc',
            failed_at: '2009-01-20T10:23:11Z',
            failed_content_type: 'text/html; charset=UTF-8',
          }
          @db.pages << input_page

          # Validate page before reparse
          gid = @db.pages.first['gid']
          job_id = @db.job_id
          expected_before_reparse = [{
            'gid' => gid,
            'job_id' => job_id,
            'status' => 'parsed',
            'url' => 'https://www.example.com/abc',
            'method' => 'POST',
            'headers' => {
              'Cookie' => 'abc=123'
            },
            'fetch_type' => 'browser',
            'cookie' => 'bbb=BBB',
            'no_redirect' => true,
            'body' => 'aaa=AAA',
            'ua_type' => 'mobile',
            'no_url_encode' => true,
            'http2' => true,
            'vars' => {},
            'freshness' => '2019-01-20T10:20:30Z',
            'to_fetch' => '2019-01-20T10:20:30Z',
            'fetching_at' => '2009-01-20T10:25:45Z',
            'fetched_at' => '2009-01-20T10:26:25Z',
            'fetching_try_count' => 2,
            'effective_url' => 'https://www.example.com/abc',
            'parsing_at' => '2019-01-20T10:26:50Z',
            'parsing_failed_at' => '2019-01-20T10:26:30Z',
            'parsed_at' => '2019-01-20T10:26:55Z',
            'parsing_try_count' => 3,
            'parsing_fail_count' => 2,
            'parsing_updated_at' => '2019-01-20T10:26:55Z',
            'response_checksum' => '123abc',
            'response_status' => '200 OK',
            'response_status_code' => '200',
            'response_headers' => {
              "Connection" => [
                "keep-alive",
                "Transfer-Encoding"
              ],
              "Content-Encoding" => [
                "gzip"
              ]
            },
            'response_cookie' => 'aaa=111',
            'response_proto' => 'HTTP/1.1',
            'content_type' => 'text/html; charset=UTF-8',
            'content_size' => 48126,
            'failed_response_status_code' => 500,
            'failed_response_headers' => {
              "Connection" => [
                "Transfer-Encoding"
              ],
              "Content-Encoding" => [
                "gzip"
              ]
            },
            'failed_response_cookie' => 'bbb=222',
            'failed_effective_url' => 'https://www.example.com/abc',
            'failed_at' => '2009-01-20T10:23:11Z',
            'failed_content_type' => 'text/html; charset=UTF-8'
          }]
          assert_equal expected_before_reparse, @db.pages

          # Validate page after reparse
          @db.reparse job_id, gid
          expected_after_reparse = [{
            'gid' => gid,
            'job_id' => job_id,
            'status' => 'to_parse',
            'url' => 'https://www.example.com/abc',
            'method' => 'POST',
            'headers' => {
              'Cookie' => 'abc=123'
            },
            'fetch_type' => 'browser',
            'cookie' => 'bbb=BBB',
            'no_redirect' => true,
            'body' => 'aaa=AAA',
            'ua_type' => 'mobile',
            'no_url_encode' => true,
            'http2' => true,
            'vars' => {},

            'freshness' => '2019-01-20T10:20:30Z',
            'to_fetch' => '2019-01-20T10:20:30Z',
            'fetching_at' => '2009-01-20T10:25:45Z',
            'fetched_at' => '2009-01-20T10:26:25Z',
            'fetching_try_count' => 2,
            'effective_url' => 'https://www.example.com/abc',
            'parsing_at' => nil,
            'parsing_failed_at' => nil,
            'parsed_at' => nil,
            'parsing_try_count' => 0,
            'parsing_fail_count' => 0,
            'parsing_updated_at' => '2001-01-01T00:00:00Z',
            'response_checksum' => '123abc',
            'response_status' => '200 OK',
            'response_status_code' => '200',
            'response_headers' => {
              "Connection" => [
                "keep-alive",
                "Transfer-Encoding"
              ],
              "Content-Encoding" => [
                "gzip"
              ]
            },
            'response_cookie' => 'aaa=111',
            'response_proto' => 'HTTP/1.1',
            'content_type' => 'text/html; charset=UTF-8',
            'content_size' => 48126,
            'failed_response_status_code' => 500,
            'failed_response_headers' => {
              "Connection" => [
                "Transfer-Encoding"
              ],
              "Content-Encoding" => [
                "gzip"
              ]
            },
            'failed_response_cookie' => 'bbb=222',
            'failed_effective_url' => 'https://www.example.com/abc',
            'failed_at' => '2009-01-20T10:23:11Z',
            'failed_content_type' => 'text/html; charset=UTF-8'
          }]
          assert_equal expected_after_reparse, @db.pages
        end
      end
    end
  end

  describe 'integration test' do
    describe 'ensure job' do
      before do
        @db = AeEasy::Core::Mock::FakeDb.new
      end

      it 'should create job when set to null' do
        assert_equal 1, @db.jobs.count
        assert_equal 1, @db.job_id
        scraper_name = @db.scraper_name
        @db.job_id = nil
        assert_equal 2, @db.job_id
        assert_equal 2, @db.jobs.count
        data = @db.jobs[1]
        assert_equal 2, data['job_id']
        assert_kind_of String, data['scraper_name']
        refute_equal '', data['scraper_name'].strip
        assert_equal scraper_name, data['scraper_name']
        assert_equal 'active', data['status']
      end

      it 'should create job when new job_id is set' do
        assert_equal 1, @db.jobs.count
        assert_equal 1, @db.job_id
        scraper_name = @db.scraper_name
        @db.job_id = 123
        assert_equal 123, @db.job_id
        assert_equal 2, @db.jobs.count
        data = @db.jobs[1]
        assert_equal 123, data['job_id']
        assert_kind_of String, data['scraper_name']
        refute_equal '', data['scraper_name'].strip
        assert_equal scraper_name, data['scraper_name']
        assert_equal 'active', data['status']
      end

      it 'should create new job when an output is inserted' do
        assert_equal 1, @db.jobs.count
        @db.enable_job_id_override
        @db.outputs << {'_job_id' => 222, 'aaa' => 'AAA'}
        assert_equal 2, @db.jobs.count
        assert_equal 222, @db.jobs.last['job_id']
      end

      it 'should create new job when a page is inserted' do
        assert_equal 1, @db.jobs.count
        @db.enable_job_id_override
        @db.pages << {'job_id' => 333, 'url' => 'http://www.example.com'}
        assert_equal 2, @db.jobs.count
        assert_equal 333, @db.jobs.last['job_id']
      end
    end

    describe 'query jobs' do
      before do
        @db = AeEasy::Core::Mock::FakeDb.new
        @db.jobs.clear
        @db.job_id = 111
        @db.scraper_name = 'AAA'
        @db.jobs << {
          'job_id' => 111,
          'scraper_name' => 'AAA',
          'status' => 'done'
        }
        @db.jobs << {
          'job_id' => 222,
          'scraper_name' => 'AAA',
          'status' => 'done'
        }
        @db.jobs << {
          'job_id' => 333,
          'scraper_name' => 'BBB',
          'status' => 'done'
        }
        @db.jobs << {
          'job_id' => 444,
          'scraper_name' => 'BBB',
          'status' => 'cancelled'
        }
        @db.jobs << {
          'job_id' => 555,
          'scraper_name' => 'BBB',
          'status' => 'cancelled'
        }
      end

      it 'should return empty when no jobs' do
        @db.jobs.clear
        assert_empty @db.jobs
        data = @db.query :jobs, {'scraper_name' => 'BBB'}
        assert_equal [], data
      end

      it 'should filter jobs' do
        data = @db.query :jobs, {'status' => 'cancelled'}
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['job_id'] <=> b['job_id']}
        assert_equal 444, data[0]['job_id']
        assert_equal 555, data[1]['job_id']
      end

      it 'should query all jobs when no filters' do
        data = @db.query :jobs, {}
        assert_operator data.count, :==, 5
        data.sort{|a,b|a['job_id'] <=> b['job_id']}
        assert_equal 111, data[0]['job_id']
        assert_equal 222, data[1]['job_id']
        assert_equal 333, data[2]['job_id']
        assert_equal 444, data[3]['job_id']
        assert_equal 555, data[4]['job_id']
      end

      it 'should limit without offset' do
        data = @db.query :jobs, {}, 0, 2
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['job_id'] <=> b['job_id']}
        assert_equal 111, data[0]['job_id']
        assert_equal 222, data[1]['job_id']
      end

      it 'should limit with offset' do
        data = @db.query :jobs, {}, 2, 2
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['job_id'] <=> b['job_id']}
        assert_equal 333, data[0]['job_id']
        assert_equal 444, data[1]['job_id']
      end

      it 'should offset without limit' do
        data = @db.query :jobs, {}, 1
        assert_operator data.count, :==, 4
        data.sort{|a,b|a['job_id'] <=> b['job_id']}
        assert_equal 222, data[0]['job_id']
        assert_equal 333, data[1]['job_id']
        assert_equal 444, data[2]['job_id']
        assert_equal 555, data[3]['job_id']
      end

      it 'should limit with offset and filters' do
        data = @db.query :jobs, {'status' => 'done'}, 1, 2
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['job_id'] <=> b['job_id']}
        assert_equal 222, data[0]['job_id']
        assert_equal 333, data[1]['job_id']
      end
    end

    describe 'query pages' do
      before do
        @db = AeEasy::Core::Mock::FakeDb.new
        @db.pages << {
          'url' => 'https://abc.com/a',
          'no_redirect' => true,
          'method' => 'GET',
          'ua_type' => 'desktop'
        }
        @db.pages << {
          'url' => 'https://abc.com/b',
          'no_redirect' => true,
          'method' => 'GET',
          'ua_type' => 'desktop'
        }
        @db.pages << {
          'url' => 'https://abc.com/c',
          'no_redirect' => true,
          'method' => 'POST',
          'ua_type' => 'desktop'
        }
        @db.pages << {
          'url' => 'https://abc.com/d',
          'no_redirect' => true,
          'method' => 'POST',
          'ua_type' => 'mobile'
        }
        @db.pages << {
          'url' => 'https://abc.com/e',
          'no_redirect' => true,
          'method' => 'POST',
          'ua_type' => 'mobile'
        }
      end

      it 'should return empty when no pages' do
        @db.pages.clear
        assert_empty @db.pages
        data = @db.query :pages, {'method' => 'GET'}
        assert_equal [], data
      end

      it 'should filter pages' do
        data = @db.query :pages, {'ua_type' => 'mobile'}
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['url'] <=> b['url']}
        assert_equal 'https://abc.com/d', data[0]['url']
        assert_equal 'https://abc.com/e', data[1]['url']
      end

      it 'should query all pages when no filters' do
        data = @db.query :pages, {}
        assert_operator data.count, :==, 5
        data.sort{|a,b|a['url'] <=> b['url']}
        assert_equal 'https://abc.com/a', data[0]['url']
        assert_equal 'https://abc.com/b', data[1]['url']
        assert_equal 'https://abc.com/c', data[2]['url']
        assert_equal 'https://abc.com/d', data[3]['url']
        assert_equal 'https://abc.com/e', data[4]['url']
      end

      it 'should limit without offset' do
        data = @db.query :pages, {}, 0, 2
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['url'] <=> b['url']}
        assert_equal 'https://abc.com/a', data[0]['url']
        assert_equal 'https://abc.com/b', data[1]['url']
      end

      it 'should limit with offset' do
        data = @db.query :pages, {}, 2, 2
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['url'] <=> b['url']}
        assert_equal 'https://abc.com/c', data[0]['url']
        assert_equal 'https://abc.com/d', data[1]['url']
      end

      it 'should offset without limit' do
        data = @db.query :pages, {}, 1
        assert_operator data.count, :==, 4
        data.sort{|a,b|a['url'] <=> b['url']}
        assert_equal 'https://abc.com/b', data[0]['url']
        assert_equal 'https://abc.com/c', data[1]['url']
        assert_equal 'https://abc.com/d', data[2]['url']
        assert_equal 'https://abc.com/e', data[3]['url']
      end

      it 'should limit with offset and filters' do
        data = @db.query :pages, {'method' => 'POST'}, 1, 2
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['url'] <=> b['url']}
        assert_equal 'https://abc.com/d', data[0]['url']
        assert_equal 'https://abc.com/e', data[1]['url']
      end
    end

    describe 'query outputs' do
      before do
        @db = AeEasy::Core::Mock::FakeDb.new
        @db.outputs << {
          'aaa' => 'A1',
          'bbb' => 222,
          'ccc' => '333',
          'ddd' => 'DDD'
        }
        @db.outputs << {
          'aaa' => 'A2',
          'bbb' => 222,
          'ccc' => '333',
          'ddd' => 'DDD'
        }
        @db.outputs << {
          'aaa' => 'A3',
          'bbb' => 222,
          'ccc' => 'CCC',
          'ddd' => 'DDD'
        }
        @db.outputs << {
          'aaa' => 'A4',
          'bbb' => 222,
          'ccc' => 'CCC',
          'ddd' => '444'
        }
        @db.outputs << {
          'aaa' => 'A5',
          'bbb' => 222,
          'ccc' => 'CCC',
          'ddd' => '444'
        }
      end

      it 'should return empty when no outputs' do
        @db.outputs.clear
        assert_empty @db.outputs
        data = @db.query :outputs, {'bbb' => 222}
        assert_equal [], data
      end

      it 'should filter outputs' do
        data = @db.query :outputs, {'ddd' => '444'}
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['aaa'] <=> b['aaa']}
        assert_equal 'A4', data[0]['aaa']
        assert_equal 'A5', data[1]['aaa']
      end

      it 'should query all outputs when no filters' do
        data = @db.query :outputs, {}
        assert_operator data.count, :==, 5
        data.sort{|a,b|a['aaa'] <=> b['aaa']}
        assert_equal 'A1', data[0]['aaa']
        assert_equal 'A2', data[1]['aaa']
        assert_equal 'A3', data[2]['aaa']
        assert_equal 'A4', data[3]['aaa']
        assert_equal 'A5', data[4]['aaa']
      end

      it 'should limit without offset' do
        data = @db.query :outputs, {}, 0, 2
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['aaa'] <=> b['aaa']}
        assert_equal 'A1', data[0]['aaa']
        assert_equal 'A2', data[1]['aaa']
      end

      it 'should limit with offset' do
        data = @db.query :outputs, {}, 2, 2
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['aaa'] <=> b['aaa']}
        assert_equal 'A3', data[0]['aaa']
        assert_equal 'A4', data[1]['aaa']
      end

      it 'should offset without limit' do
        data = @db.query :outputs, {}, 1
        assert_operator data.count, :==, 4
        data.sort{|a,b|a['aaa'] <=> b['aaa']}
        assert_equal 'A2', data[0]['aaa']
        assert_equal 'A3', data[1]['aaa']
        assert_equal 'A4', data[2]['aaa']
        assert_equal 'A5', data[3]['aaa']
      end

      it 'should limit with offset and filters' do
        data = @db.query :outputs, {'ccc' => 'CCC'}, 1, 2
        assert_operator data.count, :==, 2
        data.sort{|a,b|a['aaa'] <=> b['aaa']}
        assert_equal 'A4', data[0]['aaa']
        assert_equal 'A5', data[1]['aaa']
      end
    end
  end
end
