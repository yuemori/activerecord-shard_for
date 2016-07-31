module ActiveRecord
  module ShardFor
    class DistkeyRouter < ConnectionRouter
      # @param [Object] key sharding key
      # @return [Object] key given key
      def route(key)
        key
      end
    end
  end
end
