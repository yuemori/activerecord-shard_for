module ActiveRecord
  module ShardFor
    class STIShardRepository < AbstractShardRepository
      attr_reader :inherited_class

      # @param [Class] A sub class of AR model.
      # @base_shards [Array<Class>] An array of shard models.
      def initialize(inherited_class, base_shards)
        @inherited_class = inherited_class

        @shards = base_shards.each_with_object({}) do |(connection_name, base_model), hash|
          model = generate_model_from_shard(connection_name, base_model)
          inherited_class.const_set(:"#{generate_shard_name(connection_name)}", model)
          hash[connection_name] = model
        end
      end

      private

      # @param [Symbol] connection_name
      # @param [Class] A class of shard model.
      # @return [Class] A sub class of given model.
      def generate_model_from_shard(connection_name, base_model)
        shard_name = generate_shard_name(connection_name)
        module_name = inherited_class.name

        model = Class.new(base_model) do
          @assigned_key = base_model.assigned_key

          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.name
              "#{module_name}::#{shard_name}"
            end
          RUBY
        end
        model
      end
    end
  end
end
