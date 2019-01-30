require 'time'
require 'answersengine'
require 'ae_easy-core/smart_collection'
require 'ae_easy-core/plugin'
require 'ae_easy-core/helper'
require 'ae_easy-core/config'
require 'ae_easy-core/mock'
require 'ae_easy-core/version'

module AeEasy
  module Core
    class << self
      # Get AeEasy-core gem root directory path.
      # @private
      #
      # @return [String]
      def gem_root
        File.expand_path File.join(File.dirname(__FILE__), '..')
      end

      # Execute an action for all scripts within a directory.
      #
      # @param [String] dir Directory containing `.rb` scripts.
      # @param [Hash] opts ({}) Configuration options.
      # @option opts [Array] :except (nil) Literal file collection excluded from process.
      #
      # @yieldparam [String] path Script file path.
      def all_scripts dir, opts = {}, &block
        excluded_files = opts[:except] || []
        files = Dir[File.join(dir, '*.rb')] - excluded_files
        block ||= proc{}
        files.sort.each &block
      end

      # Require all scripts within a directory.
      #
      # @param [String] dir Directory containing `.rb` scripts.
      # @param [Hash] opts ({}) Configuration options.
      # @option opts [Array] :except (nil) Literal file collection excluded from process.
      def require_all dir, opts = {}
        all_scripts(dir, opts) {|file| require file}
      end

      # Require all relative scripts paths within a directory.
      #
      # @param [String] dir Directory containing `.rb` scripts.
      # @param [Hash] opts ({}) Configuration options.
      # @option opts [Array] :except (nil) Literal file collection excluded from process.
      def require_relative_all dir, opts = {}
        all_scripts(dir, opts) {|file| require_relative file}
      end

      # Include all scripts within a directory.
      #
      # @param [String] dir Directory containing `.rb` scripts.
      # @param [Hash] opts ({}) Configuration options.
      # @option opts [Array] :except (nil) Literal file collection excluded from process.
      def include_all dir, opts = {}
        all_scripts(dir, opts) {|file| include file}
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
      def instance_methods_from object
        object.methods(false) - Object.new.methods(false)
      end

      # Mock instances methods from the source into target object.
      #
      # @param source Object with instance methods to mock.
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
      #   source = Boo.new
      #   target = Foo.new
      #   AeEasy::Core.mock_instance_methods source target
      #
      #   puts target.hello_world
      #   # => 'Hello world!'
      #   puts target.hello_person
      #   # => 'Hello person!'
      #
      #   source.message = 'Hello world again!'
      #   puts target.hello_world
      #   # => 'Hello world again!'
      def mock_instance_methods source, target
        # Get instance unique methods
        method_list = instance_methods_from source
        method_list.delete :context_binding if method_list.include? :context_binding

        # Build env reflecting source unique methods
        env = {}
        method_list.each do |method|
          env[method] = lambda{|*args|source.send(method, *args)}
        end

        # Mock source unique methods into target
        expose_to target, env
      end

      # Generate a compatibility report from a source and a fragment as a hash.
      #
      # @param [Array] source Item collection to represent the universe.
      # @param [Array] fragment Item collection to compare againt +source+.
      #
      # @return [Hash]
      #   * `:missing [Array]` (`[]`) Methods on `fragment` only.
      #   * `:new [Array]` (`[]`) Methods on `source` only.
      #   * `:is_compatible [Boolean]` true when all `fragment`'s methods are present on `source`.
      #
      # @example Analyze when uncompatible `fragment` because of `source` missing fields.
      #   analyze_compatibility [1,2,3,4,5], [1,2,6]
      #   # => {missing: [6], new: [3,4,5], is_compatible: false}
      #
      # @example Analyze when compatible.
      #   analyze_compatibility [1,2,3,4,5], [1,2,3]
      #   # => {missing: [], new: [4,5], is_compatible: true}
      def analyze_compatibility source, fragment
        intersection = source & fragment
        {
          missing: fragment - intersection,
          new: source - intersection,
          is_compatible: (intersection.count == fragment.count)
        }
      end
    end
  end
end
