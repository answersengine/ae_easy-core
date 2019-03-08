require 'test_helper'

describe 'cookie helper' do
  describe 'unit test' do
    describe 'with cookie hash' do
      it 'should parse cookie from request cookies hash' do
        cookies = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        cookie_hash = {
          'aaa' => '000',
          'ddd' => '444'
        }
        expected = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333',
          'ddd' => '444'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_request cookies, cookie_hash
        assert_equal data, expected
        assert_equal cookie_hash, expected
      end

      it 'should parse cookie from request cookies array' do
        cookies = [
          'aaa=111',
          'bbb=222',
          'ccc=333'
        ]
        cookie_hash = {
          'aaa' => '000',
          'ddd' => '444'
        }
        expected = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333',
          'ddd' => '444'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_request cookies, cookie_hash
        assert_equal data, expected
        assert_equal cookie_hash, expected
      end

      it 'should parse cookie from request cookies raw string' do
        cookies = 'aaa=111; bbb=222; ccc=333'
        cookie_hash = {
          'aaa' => '000',
          'ddd' => '444'
        }
        expected = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333',
          'ddd' => '444'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_request cookies, cookie_hash
        assert_equal data, expected
        assert_equal cookie_hash, expected
      end

      it 'should parse cookie from response cookies hash' do
        cookies = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        cookie_hash = {
          'aaa' => '000',
          'ddd' => '444'
        }
        expected = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333',
          'ddd' => '444'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_response cookies, cookie_hash
        assert_equal data, expected
        assert_equal cookie_hash, expected
      end

      it 'should parse cookie from response cookies array' do
        cookies = [
          'aaa=111; Expires=Thu, Jan 01 1970 00:00:00 UTC; path=/',
          'bbb=222; path=/',
          'ccc=333; path=/; expires=Wed, Jan 01 2020 00:00:00 UTC'
        ]
        cookie_hash = {
          'aaa' => '000',
          'ddd' => '444'
        }
        expected = {
          'bbb' => '222',
          'ccc' => '333',
          'ddd' => '444'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_response cookies, cookie_hash
        assert_equal data, expected
        assert_equal cookie_hash, expected
      end

      it 'should parse cookie from response cookies raw string' do
        cookies = 'aaa=111; bbb=222; ccc=333'
        cookie_hash = {
          'aaa' => '000',
          'ddd' => '444'
        }
        expected = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333',
          'ddd' => '444'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_response cookies, cookie_hash
        assert_equal data, expected
        assert_equal cookie_hash, expected
      end
    end

    describe 'without cookie hash' do
      it 'should parse cookie from request cookies hash' do
        cookies = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        expected = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_request cookies
        assert_equal data, expected
      end

      it 'should parse cookie from request cookies array' do
        cookies = [
          'aaa=111',
          'bbb=222',
          'ccc=333'
        ]
        expected = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_request cookies
        assert_equal data, expected
      end

      it 'should parse cookie from request cookies raw string' do
        cookies = 'aaa=111; bbb=222; ccc=333'
        expected = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_request cookies
        assert_equal data, expected
      end

      it 'should parse cookie from response cookies hash' do
        cookies = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        expected = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_response cookies
        assert_equal data, expected
      end

      it 'should parse cookie from response cookies array' do
        cookies = [
          'aaa=111; Expires=Thu, Jan 01 1970 00:00:00 UTC; path=/',
          'bbb=222; path=/',
          'ccc=333; path=/; expires=Wed, Jan 01 2020 00:00:00 UTC'
        ]
        expected = {
          'bbb' => '222',
          'ccc' => '333'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_response cookies
        assert_equal data, expected
      end

      it 'should parse cookie from response cookies raw string' do
        cookies = 'aaa=111; bbb=222; ccc=333'
        expected = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        data = AeEasy::Core::Helper::Cookie.parse_from_response cookies
        assert_equal data, expected
      end
    end

    it 'should encode header' do
      cookie_hash = {
        'aaa' => '111',
        'bbb' => '222',
        'ccc' => '333'
      }
      expected = 'aaa=111; bbb=222; ccc=333'
      data = AeEasy::Core::Helper::Cookie.encode_to_header cookie_hash
      assert_equal data, data
    end

    describe 'should validate if cookie hash is included within other cookie hash' do
      it 'when success full filter' do
        origin = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        filter = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }

        assert AeEasy::Core::Helper::Cookie.include?(origin, filter)
      end

      it 'when success fragment' do
        origin = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        filter = {
          'aaa' => '111',
          'ccc' => '333'
        }

        assert AeEasy::Core::Helper::Cookie.include?(origin, filter)
      end

      it 'when partial match fragment' do
        origin = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        filter = {
          'ddd' => '444',
          'ccc' => '333'
        }

        refute AeEasy::Core::Helper::Cookie.include?(origin, filter)
      end

      it 'when different value fragment' do
        origin = {
          'aaa' => '111',
          'bbb' => '222',
          'ccc' => '333'
        }
        filter = {
          'aaa' => '222',
          'ccc' => '333'
        }

        refute AeEasy::Core::Helper::Cookie.include?(origin, filter)
      end
    end
  end

  describe 'integration test' do
    it 'should update as hash' do
      request_cookies = 'aaa=111; bbb=222; ccc=333'
      response_cookies = [
        'aaa=deleted; Expires=Thu, Jan 01 1970 00:00:00 UTC; path=/',
        'bbb=555; path=/',
        'ddd=444; path=/; expires=Wed, Jan 01 2020 00:00:00 UTC'
      ]
      expected = {
        'bbb' => '555',
        'ccc' => '333',
        'ddd' => '444'
      }
      data = AeEasy::Core::Helper::Cookie.update_as_hash request_cookies, response_cookies
      assert_equal data, expected
    end

    it 'should update request cookies with response cookies' do
      request_cookies = 'aaa=111; bbb=222; ccc=333'
      response_cookies = [
        'aaa=deleted; Expires=Thu, Jan 01 1970 00:00:00 UTC; path=/',
        'bbb=555; path=/',
        'ddd=444; path=/; expires=Wed, Jan 01 2020 00:00:00 UTC'
      ]
      expected = 'bbb=555; ccc=333; ddd=444'
      data = AeEasy::Core::Helper::Cookie.update request_cookies, response_cookies
      assert_equal data, expected
    end
  end
end
