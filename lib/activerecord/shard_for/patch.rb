module ActiveRecord
  module ShardFor
    module Patch
      extend ActiveSupport::Concern

      module ClassMethods
        # For ActiveRecord::Enum patch.
        # See https://github.com/yuemori/activerecord-shard_for/issues/10
        def enum(definitions)
          super
          shard_repository.all.each { |shard| shard.defined_enums = defined_enums }
        end

        # For ActiveSupport::Callbacks patch.
        #
        # Since define_callbacks has not been successfully propagated to the shard class when called,
        # we also call define_callback of the shard class.
        def define_callbacks(*args)
          if abstract_class
            all_shards.each do |model|
              model.define_callbacks(*args)
            end
          end

          super
        end
      end
    end
  end
end
