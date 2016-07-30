require 'spec_helper'

RSpec.describe ActiveRecord::ShardFor::HashModuloRouter do
  let(:router) { described_class.new(cluster_config) }
  let(:cluster_config) { ActiveRecord::ShardFor.config.fetch_cluster_config(:user) }

  describe '#fetch_connection_name' do
    subject { router.fetch_connection_name(id) }

    where(:id, :shard_name) do
      [
        ['d', :test_user_001],
        ['b', :test_user_002],
        ['e', :test_user_003],
        ['c', :test_user_004]
      ]
    end

    with_them do
      it { is_expected.to eq shard_name }
    end
  end
end
