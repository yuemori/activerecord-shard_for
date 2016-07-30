module ActiveRecord
  module ShardFor
    class ClusterConfig
      attr_reader :name, :connection_registry

      # @param [Symbol] name
      def initialize(name)
        @name = name
        @connection_registry = {}
      end

      # @param [Integer] index index number for connection
      # @param [Symbol] connection_name
      # @raise [RuntimeError] when duplicate entry for index
      def register(index, connection_name)
        raise RuntimeError.new, "#{index} is registered" if connection_registry.key?(index)
        connection_registry[index] = connection_name
      end

      # @return [Array<Symbol>] An array of connection name
      def connections
        connection_registry.values
      end
    end
  end
end
