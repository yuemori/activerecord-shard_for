module ActiveRecord
  module ShardFor
    class Config
      attr_reader :cluster_configs

      def initialize
        @cluster_configs = {}.with_indifferent_access
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
    end
  end
end
