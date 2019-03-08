require 'time'
require 'faker'
require 'answersengine'
require 'ae_easy/core/smart_collection'
require 'ae_easy/core/exception'
require 'ae_easy/core/plugin'
require 'ae_easy/core/helper'
require 'ae_easy/core/config'
require 'ae_easy/core/mock'
require 'ae_easy/core/version'

module AeEasy
  module Core
    class << self
      # Get AeEasy-core gem root directory path.
      # @private
      #
      # @return [String]
      def gem_root
        File.expand_path File.join(File.dirname(__FILE__), '../..')
      end

      # Execute an action for all scripts within a directory.
      #
      # @param [String] dir Directory containing `.rb` scripts.
      # @param [Hash] opts ({}) Configuration options.
      # @option opts [Array] :except (nil) Literal file collection excluded from process.
      #
      # @yieldparam [String] path Script file path.
      def all_scripts dir, opts = {}, &block
        excluded_files = (opts[:except] || []).map{|f|File.expand_path File.join(dir, f)}
        files = Dir[File.join(File.expand_path(dir), '*.rb')] - excluded_files
        block ||= proc{}
        files.sort.each &block
      end

      # Require all scripts within a directory.
      #
      # @param [String] dir Directory containing `.rb` scripts.
      # @param [Hash] opts ({}) Configuration options.
      # @option opts [Array] :except (nil) Literal file collection excluded from process.
      def require_all dir, opts = {}
        dir_list = real_dir_list = options = nil
        real_except = (opts[:except] || []).map{|f| "#{f}.rb"}
        options = opts.merge except: real_except
        $LOAD_PATH.each do |load_path|
          dir_list = Dir.glob File.join(load_path, dir)
          dir_list.each do |real_dir|
            next unless File.directory? real_dir
            all_scripts(real_dir, options) {|file| require file}
          end
        end
      end

      # Require all relative scripts paths within a directory.
      #
      # @param [String] dir Directory containing `.rb` scripts.
      # @param [Hash] opts ({}) Configuration options.
      # @option opts [Array] :except (nil) Literal file collection excluded from process.
      def require_relative_all dir, opts = {}
        real_except = (opts[:except] || []).map{|f| "#{f}.rb"}
        options = opts.merge except: real_except
        dir_list = Dir.glob dir
        dir_list.each do |relative_dir|
          real_dir = File.expand_path relative_dir
          all_scripts(real_dir, options) {|file| require file}
        end
      end

      # Expose an environment into an object instance as methods.
      #
      # @param object Object instance to expose env into.
      # @param [Array] env Hash with methods name as keys and blocks as actions.
      #
      # @return `object`
      #
      # @example
      #   class Foo
      #     def hello_person
      #       'Hello person!'
      #     end
      #   end
      #
      #   env = {
      #     hello_world: lambda{return 'Hello world!'},
      #     hello_sky: proc{return 'Hello sky!'}
      #   }
      #   my_object = Foo.new
      #   AeEasy::Core.expose_to my_object, env
      #
      #   puts my_object.hello_world
      #   # => 'Hello world!'
      #   puts my_object.hello_sky
      #   # => 'Hello sky!'
      #   puts my_object.hello_person
      #   # => 'Hello person!'
      def expose_to object, env
        metaclass = class << object; self; end
        env.each do |key, block|
          metaclass.send(:define_method, key, block)
        end
        object
      end

      # Retrieve instance methods from an object.
      #
      # @param object Object with instance methods.
      # @param class_only (false) Will get class only methods when `true`.
      #
      # @return [Array]
      #
      # @example
      #   class Foo
      #     def hello_world
      #       'Hello world!'
      #     end
      #
      #     def hello_person
      #       'Hello person!'
      #     end
      #   end
      #
      #   my_object = Foo.new
      #   AeEasy::Core.instance_methods_from my_object
      #   # => [:hello_world, :hello_person]
      def instance_methods_from object, class_only = false
        object.methods(!class_only) - Object.new.methods(!class_only)
      end

      # Mock instances methods from the origin into target object.
      #
      # @param origin Object with instance methods to mock.
      # @param target Object instance to mock methods into.
      #
      # @example
      #   class Boo
      #     attr_accessor :message
      #     def initialize
      #       message = 'Hello world!'
      #     end
      #
      #     def hello_world
      #       message
      #     end
      #   end
      #
      #   class Foo
      #     def hello_person
      #       'Hello person!'
      #     end
      #   end
      #
      #   origin = Boo.new
      #   target = Foo.new
      #   AeEasy::Core.mock_instance_methods origin target
      #
      #   puts target.hello_world
      #   # => 'Hello world!'
      #   puts target.hello_person
      #   # => 'Hello person!'
      #
      #   origin.message = 'Hello world again!'
      #   puts target.hello_world
      #   # => 'Hello world again!'
      def mock_instance_methods origin, target
        # Get instance unique methods
        method_list = instance_methods_from origin
        method_list.delete :context_binding if method_list.include? :context_binding

        # Build env reflecting origin unique methods
        env = {}
        method_list.each do |method|
          env[method] = lambda{|*args|origin.send(method, *args)}
        end

        # Mock origin unique methods into target
        expose_to target, env
      end

      # Generate a compatibility report from a origin and a fragment as a hash.
      #
      # @param [Array] origin Item collection to represent the universe.
      # @param [Array] fragment Item collection to compare againt +origin+.
      #
      # @return [Hash]
      #   * `:missing [Array]` (`[]`) Methods on `fragment` only.
      #   * `:new [Array]` (`[]`) Methods on `origin` only.
      #   * `:is_compatible [Boolean]` true when all `fragment`'s methods are present on `origin`.
      #
      # @example Analyze when uncompatible `fragment` because of `origin` missing fields.
      #   AeEasy::Core.analyze_compatibility [1,2,3,4,5], [1,2,6]
      #   # => {missing: [6], new: [3,4,5], is_compatible: false}
      #
      # @example Analyze when compatible.
      #   AeEasy::Core.analyze_compatibility [1,2,3,4,5], [1,2,3]
      #   # => {missing: [], new: [4,5], is_compatible: true}
      def analyze_compatibility origin, fragment
        intersection = origin & fragment
        {
          missing: fragment - intersection,
          new: origin - intersection,
          is_compatible: (intersection.count == fragment.count)
        }
      end

      # Deep stringify keys from a hash.
      #
      # @param [Hash] hash Source hash to stringify keys.
      # @param [Boolean] should_clone (true) Target a hash clone to avoid affecting the same hash object.
      #
      # @return [Hash]
      def deep_stringify_keys hash, should_clone = true
        return hash unless hash.is_a? Hash
        pair_collection = hash.map{|k,v| [k.to_s,v]}
        target = should_clone ? {} : hash
        target.clear
        pair_collection.each do |pair|
          key, value = pair
          if value.is_a? Array
            array = []
            value.each do |item|
              array << deep_stringify_keys(item, should_clone)
            end
            target[key] = array
            next
          end
          target[key] = deep_stringify_keys(value, should_clone)
        end
        target
      end

      # Deep stringify all keys on hash object.
      #
      # @param [Hash] hash Hash to stringify keys.
      #
      # @return [Hash]
      def deep_stringify_keys! hash
        deep_stringify_keys hash, false
      end

      # Deep clone a hash while keeping it's values object references.
      #
      # @param [Hash] hash Hash to clone.
      # @param [Boolean] should_clone (false) Clone values when true.
      #
      # @return [Hash] Hash clone.
      def deep_clone hash, should_clone = false
        target = {}
        hash.each do |key, value|
          value = value.is_a?(Hash) ? deep_clone(value, should_clone) : (should_clone ? value.clone : value)
          target[key] = value
        end
        target
      end
    end
  end
end
