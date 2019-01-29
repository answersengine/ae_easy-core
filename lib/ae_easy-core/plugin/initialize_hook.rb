module AeEasy
  module Core
    module Plugin
      module InitializeHook
        def initialize_hooks opts = {}
          initializers = self.methods.select{|i|i.to_s =~ /^initialize_hook_/}
          initializers.each do |method|
            self.send method, opts
          end
        end
      end
    end
  end
end
