require 'test_helper'

describe 'fake db' do
  describe 'unit test' do
    it 'should have page keys' do
      expected = ['gid']
      assert_equal expected, AeEasy::Core::Mock::FakeDb::PAGE_KEYS
    end

    it 'should have output keys' do
      expected = ['_id', '_collection']
      assert_equal expected, AeEasy::Core::Mock::FakeDb::OUTPUT_KEYS
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

      it 'should generate page gids consistently' do
        base_hash = {
          'url' => 0,
          'method' => 0,
          'headers' => {
            'Cookies' => 0,
            'Referer' => 0
          },
          'fetch_type' => 0,
          'cookie' => 0,
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
          else
            hash[key] = 111
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
        expected = {
          'url' => nil,
          'method' => 'GET',
          'headers' => {},
          'fetch_type' => 'standard',
          'cookie' => nil,
          'no_redirect' => false,
          'body' => nil,
          'ua_type' => 'desktop',
          'vars' => {}
        }
        assert_equal expected, @db.page_defaults
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
          id_a = @db.generate_output_id hash
          id_b = @db.generate_output_id hash

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
          ua_type: 'mobile'
        }
        @db.pages << input_page
        expected = [{
          'gid' => @db.pages.first['gid'],
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
          'url' => 'https://www.example.com/bbb',
          'method' => 'GET',
          'headers' => {},
          'fetch_type' => 'standard',
          'cookie' => nil,
          'no_redirect' => false,
          'body' => nil,
          'ua_type' => 'desktop',
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

      it 'should raise error on query when unknown collection' do
        assert_raises(ArgumentError, 'Unknown collection aaa.') do
          @db.query :aaa, {}
        end
      end

      describe 'frozen_time' do
        before do
          @time = Time.now
          @formatted_time = @time.strftime('%Y-%m-%dT%H:%M:%SZ')
          Timecop.travel @time
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

        it 'should generate output defaults' do
          @db.job_id = 444
          @db.page_gid = '555'
          data = @db.output_defaults
          keys = data.keys.sort!
          expected_keys = [
            '_collection',
            '_created_at',
            '_gid',
            '_job_id'
          ]
          assert_equal expected_keys, keys
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
      end
    end
  end

  describe 'integration test' do
    it 'should build fake page without options' do
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
        'url' => 'https://vvv.com',
        'method' => 'POST',
        'headers' => {},
        'fetch_type' => 'standard',
        'cookie' => nil,
        'no_redirect' => false,
        'body' => nil,
        'ua_type' => 'desktop',
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
        'url' => 'https://example.com',
        'method' => 'GET',
        'headers' => {},
        'fetch_type' => 'standard',
        'cookie' => nil,
        'no_redirect' => false,
        'body' => nil,
        'ua_type' => 'desktop',
        'vars' => {}
      }
      assert_equal expected, data
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
