module AeEasy
  module Core
    class SmartCollection < Array
      EVENTS = [
        :before_defaults,
        :before_match,
        :before_insert,
        :after_insert
      ]

      # Key fields, analog to primary keys.
      attr_reader :key_fields
      # Default fields values. Apply to missing fields and null values.
      attr_reader :defaults

      # Initialize collection
      #
      # @param [Array] key_fields Key fields, analog to primary keys.
      # @param [Hash] opts ({}) Configuration options.
      # @option opts [Array] :values ([]) Initial values; will avoid duplicates on insert.
      # @option opts [Hash] :defaults ({}) Default values. `proc` values will be executed to get default value.
      #
      # @example With default values.
      #   count = 0
      #   defaults = {
      #     'id' => lambda{|item| count += 1},
      #     'aaa' => 111,
      #     'bbb' => proc{|item| item['ccc'].nil? ? 'No ccc' : 'Has ccc'}
      #   }
      #   values = [
      #     {'aaa' => 'Defaults apply on nil values only', 'bbb' => nil},
      #     {'ccc' => 'ddd'},
      #     {'id' => 'abc123'}
      #   ]
      #   new_item = {'bbb' => 'Look mom! no ccc'}
      #   collection = SmartCollection.new ['id'], defaults: defaults
      #   collection << new_item
      #   collection
      #   # => [
      #   #   {'id' => 1, 'aaa' => 'Defaults apply on nil values only', 'bbb' => 'No ccc'},
      #   #   {'id' => 2, 'aaa' => 111, 'bbb' => 'Has ccc', 'ccc' => 'ddd'},
      #   #   {'id' => 'abc123', 'aaa' => 111, 'bbb' => 'No ccc'},
      #   #   {'id' => 3, 'aaa' => 111, 'bbb' => 'Look mom! no ccc'}
      #   # ]
      #
      # @note Defaults will apply to missing fields and null values only.
      def initialize key_fields, opts = {}
        @key_fields = key_fields || []
        @defaults = opts[:defaults] || {}
        super 0
        (opts[:values] || []).each{|item| self << item}
      end

      # Asigned events.
      # @private
      def events
        @events ||= {}
      end

      # Add event binding by key and block.
      #
      # @param [Symbol] key Event name.
      #
      # @raise [ArgumentError] When unknown event key.
      #
      # @note Some events will expect a return value to replace item on insertion:
      #   * `before_match`
      #   * `before_defaults`
      #   * `before_insert`
      #   * `after_insert`
      def add_event key, &block
        unless EVENTS.has_key? key
          raise ArgumentError.new("Unknown event '#{key}'")
        end
        (events[key] ||= []) << block
      end

      # Check whenever two items keys match.
      #
      # @param [Hash] item_a Item to match.
      # @param [Hash] item_b Item to match.
      #
      # @return [Boolean]
      def match_keys? item_a, item_b
        return false if key_fields.nil? || key_fields.count < 1
        return true if item_a.nil? && item_b.nil?
        return false if item_a.nil? || item_b.nil?
        key_fields.each do |key|
          return false if item_a[key] != item_b[key]
        end
        true
      end

      # Apply default values into item.
      # @private
      #
      # @param [Hash] item Item to apply defaults.
      #
      # @return [Hash] Item
      def apply_defaults item
        defaults.each do |key, value|
          next unless item[key].nil?
          value = value.respond_to?(:call) ? value.call(item) : value
        end
      end

      # Call an event
      # @private
      #
      # @param [Symbol] key Event name.
      # @params args event arguments.
      def call_event key, *args
        return if events[key].nil?
        events[key].each{|event| event.call self, *args}
      end

      # Add/remplace an item avoiding duplicates
      def << item
        item = call_event(:before_defaults, item) || item
        apply_defaults item
        item = call_event(:before_match, item) || item
        match = self.find do |existing_item|
          match_keys? existing_item, item
        end
        call_event :before_insert, item
        delete match unless match.nil? || !!match
        super(item)
        call_event :after_insert, item
      end
    end
  end
end
