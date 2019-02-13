module AeEasy
  module Core
    # Smart collection capable to avoid duplicates on insert by matching id
    #   defined fields along events.
    class SmartCollection < Array
      # Implemented event list.
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
      # @example before_defaults
      #   defaults = {'aaa' => 111}
      #   collection = SmartCollection.new [],
      #     defaults: defaults
      #   collection.bind_event(:before_defaults) do |collection, item|
      #     puts collection
      #     # => []
      #     puts item
      #     # => {'bbb' => 222}
      #
      #     # Sending the item back is required, or a new one
      #     #   in case you want to replace item to insert.
      #     item
      #   end
      #   data << {'bbb' => 222}
      #   data
      #   # => [{'aaa' => 111, 'bbb' => 222}]
      #
      # @example before_match
      #   keys = ['id']
      #   defaults = {'aaa' => 111}
      #   values = [
      #     {'id' => 1, 'ccc' => 333}
      #   ]
      #   collection = SmartCollection.new keys,
      #     defaults: defaults
      #     values: values
      #   collection.bind_event(:before_match) do |collection, item|
      #     puts collection
      #     # => [{'id' => 1, 'aaa' => 111, 'ccc' => 333}]
      #     puts item
      #     # => {'id' => 1, 'aaa' => 111, 'bbb' => 222}
      #
      #     # Sending the item back is required, or a new one
      #     #   in case you want to replace item to insert.
      #     item
      #   end
      #   data << {'id' => 1, 'bbb' => 222}
      #   data
      #   # => [{'id' => 1, 'aaa' => 111, 'bbb' => 222}]
      #
      # @example before_insert
      #   keys = ['id']
      #   defaults = {'aaa' => 111}
      #   values = [
      #     {'id' => 1, 'ccc' => 333}
      #   ]
      #   collection = SmartCollection.new keys,
      #     defaults: defaults
      #     values: values
      #   collection.bind_event(:before_insert) do |collection, item, match|
      #     puts collection
      #     # => [{'id' => 1, 'aaa' => 111, 'ccc' => 333}]
      #     puts item
      #     # => {'id' => 1, 'aaa' => 111, 'bbb' => 222}
      #     puts match
      #     # => {'id' => 1, 'aaa' => 111, 'ccc' => 333}
      #
      #     # Sending the item back is required, or a new one
      #     #   in case you want to replace item to insert.
      #     item
      #   end
      #   data << {'id' => 1, 'bbb' => 222}
      #   data
      #   # => [{'id' => 1, 'aaa' => 111, 'bbb' => 222}]
      #
      # @example after_insert
      #   keys = ['id']
      #   defaults = {'aaa' => 111}
      #   values = [
      #     {'id' => 1, 'ccc' => 333}
      #   ]
      #   collection = SmartCollection.new keys,
      #     defaults: defaults
      #     values: values
      #   collection.bind_event(:after_insert) do |collection, item, match|
      #     puts collection
      #     # => [{'id' => 1, 'aaa' => 111, 'bbb' => 222}]
      #     puts item
      #     # => {'id' => 1, 'aaa' => 111, 'bbb' => 222}
      #     puts match
      #     # => {'id' => 1, 'aaa' => 111, 'ccc' => 333}
      #     # No need to send item back since it is already inserted
      #   end
      #   data << {'id' => 1, 'bbb' => 222}
      #   data
      #   # => [{'id' => 1, 'aaa' => 111, 'bbb' => 222}]
      #
      # @note Some events will expect a return value to replace item on insertion:
      #   * `before_match`
      #   * `before_defaults`
      #   * `before_insert`
      def bind_event key, &block
        unless EVENTS.include? key
          raise ArgumentError.new("Unknown event '#{key}'")
        end
        (events[key] ||= []) << block
      end

      # Call an event
      # @private
      #
      # @param [Symbol] key Event name.
      # @param default Detault return value when event's return nil.
      # @param args event arguments.
      def call_event key, default = nil, *args
        return default if events[key].nil?
        result = nil
        events[key].each{|event| result = event.call self, *args}
        result.nil? ? default : result
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
          item[key] = value.respond_to?(:call) ? value.call(item) : value
        end
      end

      # Find an item by matching filter keys
      #
      # @param [Hash] filter
      #
      # @return [Hash|nil] First existing item match or nil when no match.
      #
      # @note _Warning:_ It uses table scan to filter and will be slow.
      def find_match filter
        self.find do |item|
          match_keys? item, filter
        end
      end

      # Add/remplace an item avoiding duplicates
      def << item
        item = call_event :before_defaults, item, item
        apply_defaults item
        item = call_event :before_match, item, item
        match = find_match item
        item = call_event :before_insert, item, item, match
        delete match unless match.nil?
        result = super(item)
        call_event :after_insert, result, item, match
      end
    end
  end
end
