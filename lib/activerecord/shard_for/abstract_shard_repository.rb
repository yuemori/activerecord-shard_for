module ActiveRecord
  module ShardFor
    class AbstractShardRepository
      attr_reader :shards

      # @param [Symbol] connection_name
      # @return [Class] A model class for this shard
      def fetch(connection_name)
        shards.fetch(connection_name)
      end

      # @param [Object] key sharding key object for connection
      # @return [Class, nil] A AR model class.
      def fetch_by_key(key)
        shards.values.find do |model|
          case model.assigned_key
          when Range then model.assigned_key.include?(key)
          else model.assigned_key == key
          end
        end
      end

      # @return [Array<Class>]
      def all
        shards.values
      end

      private

      # @param [Symbol] connection_name
      # @return [String]
      def generate_shard_name(connection_name)
        "ShardFor#{connection_name.to_s.tr('-', '_').classify}"
      end
    end
  end
end
