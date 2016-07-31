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
      # @raise [RuntimeError] when duplicate entry of  key
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
      # @raise [KeyError] when key is not registered
      def fetch(key)
        connection_registry.each do |connection_key, connection|
          case connection_key
          when Range then return connection if connection_key.include?(key)
          else return connection if connection_key == key
          end
        end

        raise KeyError.new, "#{key} is not registerd connection"
      end
    end
  end
end
