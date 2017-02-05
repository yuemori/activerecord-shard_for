module ActiveRecord
  module ShardFor
    class ShardRepository < AbstractShardRepository
      attr_reader :base_class

      # @param [ClusterConfig] cluster_config
      # @param [Class] base_class A AR Model
      def initialize(cluster_config, base_class)
        @base_class = base_class

        @shards = cluster_config.connection_registry.each_with_object({}) do |(key, connection_name), hash|
          establish_connection(connection_name)
          model = generate_model_for_shard(connection_name, key)
          base_class.const_set(:"#{generate_shard_name(connection_name)}", model)
          hash[connection_name] = model
        end
      end

      private

      # Establish connection for shard.
      # @param [Symbol] connection_name
      def establish_connection(connection_name)
        shard_name = generate_shard_name(connection_name)

        model = Class.new(base_class) do
          self.table_name = base_class.table_name

          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.name
              "#{shard_name}"
            end
          RUBY
        end

        model.establish_connection connection_name
      end

      # @param [Symbol] connection_name
      # @param [Range] slot_range
      # @return [Class] A sub class of given AR model.
      #   A sub class has connection setting for specific shard.
      def generate_model_for_shard(connection_name, key)
        shard_name = generate_shard_name(connection_name)

        Class.new(base_class) do
          self.table_name = base_class.table_name
          class << self
            attr_reader :assigned_key
          end
          @assigned_key = key

          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.name
              "#{base_class.name}::#{shard_name}"
            end
            self.connection_specification_name = "#{shard_name}"
          RUBY
        end
      end
    end
  end
end
