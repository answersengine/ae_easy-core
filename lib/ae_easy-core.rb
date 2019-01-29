require 'time'
require 'answersengine'
require 'ae_easy-core/plugin'
require 'ae_easy-core/helper'
require 'ae_easy-core/config'
require 'ae_easy-core/version'

module AeEasy
  module Core
    class << self
      def gem_root
        File.expand_path File.join(File.dirname(__FILE__), '..')
      end

      def all_scripts dir, opts = {}, &block
        excluded_files = opts[:except] || []
        files = Dir[File.join(dir, '*.rb')] - excluded_files
        block ||= proc{}
        files.sort.each &block
      end

      def require_all dir, opts = {}
        all_scripts(dir, opts) {|file| require file}
      end

      def require_relative_all dir, opts = {}
        all_scripts(dir, opts) {|file| require_relative file}
      end

      def include_all dir, opts = {}
        all_scripts(dir, opts) {|file| include file}
      end

      def expose_to object, env
        metaclass = class << object; self; end
        env.each do |key, block|
          metaclass.send(:define_method, key, block)
        end
        object
      end

      def instance_methods_from object
        object.methods(false) - Object.new.methods(false)
      end

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
    end
  end
end
