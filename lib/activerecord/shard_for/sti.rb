module ActiveRecord
  module ShardFor
    module STI
      extend ActiveSupport::Concern

      included do
        self.abstract_class = true
        self.shard_repository = STIShardRepository.new(self, superclass.shard_repository.shards)
      end
    end
  end
end
