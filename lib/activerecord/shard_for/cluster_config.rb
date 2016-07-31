module ActiveRecord
  module ShardFor
    class ClusterConfig
      attr_reader :name, :connection_registry

      # @param [Symbol] name
      def initialize(name)
        @name = name
        @connection_registry = {}
      end

      # @param [Object] key sharding key object for connection
      # @param [Symbol] connection_name
      # @raise [RuntimeError] when duplicate entry of key
      def register(key, connection_name)
        raise RuntimeError.new, "#{key} is registered" if connection_registry.key?(key)
        connection_registry[key] = connection_name
      end

      # @return [Array<Symbol>] An array of connection name
      def connections
        connection_registry.values
      end

      # @param [Object] key
      # @return [Symbol] registered connection name
      def fetch(key)
        connection_registry.find do |connection_key, _connection|
          case connection_key
          when Range then connection_key.include?(key)
          else connection_key == key
          end
        end.second
      end
    end
  end
end
