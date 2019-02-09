module AeEasy
  module Core
    module Mock
      # Fake seeder that emulates `AnswersEngine` seeder executor.
      class FakeSeeder
        include AeEasy::Core::Mock::FakeExecutor

        # Fake seeder exposed methods to isolated context.
        # @private
        #
        # @return [Array]
        def self.exposed_methods
          real_methods = AnswersEngine::Scraper::RubySeederExecutor.exposed_methods.uniq
          mock_methods = [
            :outputs,
            :pages,
            :save_pages,
            :save_outputs,
            :find_output,
            :find_outputs
          ].freeze
          AeEasy::Core::Mock::FakeExecutor.check_compatibility real_methods, mock_methods
          mock_methods
        end
      end
    end
  end
end
