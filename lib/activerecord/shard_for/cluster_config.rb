module ActiveRecord
  module ShardFor
    class ClusterConfig
      attr_reader :name, :connection_registry

      # @param [Symbol] name
      def initialize(name)
        @name = name
        @connection_registry = {}
      end

      # @param [Objet] key sharding name for connection
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
      def fetch(key)
        connection_registry.fetch(key)
      end
    end
  end
end
