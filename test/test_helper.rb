require 'simplecov'
require 'simplecov-console'
SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.start

require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'byebug'
require 'ae_easy-core'

def self.context_vars executor_class
  context = Object.new
  metaclass = class << context; self; end
  message_queue = [] # Beat reference bug
  exposed_methods = executor_class.exposed_methods
  exposed_methods.each do |key|
    metaclass.send(:define_method, key) do |*args|
      # Record all method calls into message queue for easy access
      message_queue << [key, args]
    end
  end
  [context, message_queue]
end

def self.parser_context_vars
  executor_class = AnswersEngine::Scraper::RubyParserExecutor
  context_vars executor_class
end

def self.seeder_context_vars
  executor_class = AnswersEngine::Scraper::RubySeederExecutor
  context_vars executor_class
end
