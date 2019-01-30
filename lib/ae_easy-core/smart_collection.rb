module AeEasy
  module Core
    class SmartCollection < Array
      # Key fields, analog to primary keys.
      attr_reader :key_fields

      # Initialize collection
      #
      # @param [Hash] key_fields Key fields hash with default values, analog to primary keys.
      # @param [Array] values (nil) Initial values; will avoid duplicates on insert.
      # @param args Inherith args from Array.
      def initialize key_fields, values = nil, *args
        @key_fields = key_fields || []
        super 0, *args
        (values || []).each{|item| self << item}
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
        key_fields.each do |key, value|
          return false if item_a[key] != item_b[key]
        end
        true
      end

      # Add/remplace an item avoiding duplicates
      def << new_item
        # Apply default values
        key_fields.each do |key, value|
          # Skip when default value is nil
          value = value.call if value.respond_to? :call
          next if value.nil?
          new_item[key] ||= value
        end
        match = self.find do |item|
          match_keys? item, new_item
        end
        delete match unless match.nil?
        super(new_item)
      end
    end
  end
end
