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

        establish_connection(connection_name)
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

      private

      # @param [Symbol] connection_name
      # @return [String]
      def generate_shard_name(connection_name)
        "ShardFor#{connection_name.to_s.tr('-', '_').classify}"
      end

      # Establish connection for shard.
      # @param [Symbol] connection_name
      def establish_connection(connection_name)
        shard_name = generate_shard_name(connection_name)

        model = shard_name.safe_constantize

        return if model

        model = Class.new(ActiveRecord::Base) do
          self.abstract_class = true

          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.name
              "#{shard_name}"
            end
          RUBY
        end

        Object.const_set(shard_name, model)

        model.establish_connection connection_name
      end
    end
  end
end
