module ActiveRecord
  module ShardFor
    class ShardRepository < AbstractShardRepository
      attr_reader :base_class

      # @param [ClusterConfig] cluster_config
      # @param [Class] base_class A AR Model
      def initialize(cluster_config, base_class)
        @base_class = base_class

        @shards = cluster_config.connection_registry.each_with_object({}) do |(key, connection_name), hash|
          generate_connection_publisher_unless_exist(connection_name)
          model = generate_model_for_shard(connection_name, key)
          base_class.const_set(:"#{generate_class_name(connection_name)}", model)
          hash[connection_name] = model
        end
      end

      private

      # Generate connection publisher to shard.
      # More infomation, see `establish_connection to same shard` test in the model_spec.rb.
      def generate_connection_publisher_unless_exist(connection_name)
        class_name = generate_class_name(connection_name)

        return if Object.const_defined?(:"#{class_name}")

        model = Class.new(ActiveRecord::Base) do
          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.name
              "#{class_name}"
            end
          RUBY
        end
        Object.const_set(:"#{class_name}", model)
        model.establish_connection connection_name
      end

      # @param [Symbol] connection_name
      # @param [Range] slot_range
      # @return [Class] A sub class of given AR model.
      #   A sub class has connection setting for specific shard.
      def generate_model_for_shard(connection_name, key) # rubocop:disable Metrics/MethodLength
        class_name = generate_class_name(connection_name)

        Class.new(base_class) do
          self.table_name = base_class.table_name
          class << self
            attr_reader :assigned_key
          end
          @assigned_key = key
          # For Rails5.0 only
          self.connection_specification_name = class_name if respond_to?(:connection_specification_name)

          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.name
              "#{base_class.name}::#{class_name}"
            end

            def self.connection
              ::#{class_name}.connection
            end
          RUBY
        end
      end
    end
  end
end
