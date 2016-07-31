module ActiveRecord
  module ShardFor
    class Config
      attr_reader :cluster_configs, :connection_routers

      def initialize
        @cluster_configs = {}
        @connection_routers = {}
      end

      # Define config for specific cluster.
      # See README.md for example.
      # @param [String] cluster_name
      # @yield [ActiveRecord::ShardFor::ClusterConfig]
      # @return [ActiveRecord::ShardFor::ClusterConfig]
      # raise [RuntimeError] when this cluster config is invalid.
      def define_cluster(cluster_name, &block)
        cluster_config = ClusterConfig.new(cluster_name)
        cluster_config.instance_eval(&block)
        cluster_configs[cluster_name] = cluster_config
      end

      # @param [Symbol] cluster_name
      # @return [ActiveRecord::ShardFor::ClusterConfig]
      # @raise [KeyError] when not registered key given
      def fetch_cluster_config(cluster_name)
        cluster_configs.fetch(cluster_name)
      end

      # Register connection router for ActiveRecord::ShardFor
      # See README.md for example.
      # @param [Symbol] router_name
      # @router_class [Class] router_class
      def register_connection_router(router_name, router_class)
        connection_routers[router_name] = router_class
      end

      # @param [Symbol] connection_router_name
      # @return [Class] registered class by [#register_router]
      # @raise [KeyError] when not registerd router_name given
      def fetch_connection_router(connection_router_name)
        connection_routers.fetch(connection_router_name)
      end
    end
  end
end
