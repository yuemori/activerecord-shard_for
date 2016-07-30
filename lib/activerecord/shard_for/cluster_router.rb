module ActiveRecord
  module ShardFor
    # @abstract Subclass and override [#route] to inplement
    class ClusterRouter
      attr_reader :cluster_config

      # @param [ActiveRecord::ShardFor::ClusterConfig]
      def initialize(cluster_config)
        @cluster_config = cluster_config
      end

      # Fetch shard by sharding key
      # @param [Object] key routing key
      def fetch_connection_name(key)
        cluster_config.fetch route(key)
      end

      # Decide routing for shard.
      # Override this method in subclass.
      # @param [Object] key sharding key
      def route(_key)
        raise NotImplementedError.new, 'Please impement this method'
      end

      private

      # @return [Integer] count of registered connection
      def connection_count
        cluster_config.connections.count
      end
    end
  end
end
