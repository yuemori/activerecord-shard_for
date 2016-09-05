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
      end
    end
  end
end
