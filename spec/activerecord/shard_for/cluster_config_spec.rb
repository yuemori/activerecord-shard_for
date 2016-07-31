require 'spec_helper'

RSpec.describe ActiveRecord::ShardFor::ClusterConfig do
  describe '#fetch' do
    subject { cluster_config.fetch(key) }

    let(:cluster_config) { ActiveRecord::ShardFor.config.fetch_cluster_config(cluster_name) }

    context 'when key is not range' do
      let(:cluster_name) { :user }

      where(:key, :connection) do
        [
          [0, :test_user_001],
          [1, :test_user_002],
          [2, :test_user_003],
          [3, :test_user_004]
        ]
      end

      with_them do
        it { is_expected.to eq connection }
      end
    end

    context 'when key is range' do
      let(:cluster_name) { :character }

      where(:key, :connection) do
        [
          [0, :test_character_001],
          [100, :test_character_002],
          [200, :test_character_003]
        ]
      end

      with_them do
        it { is_expected.to eq connection }
      end
    end
  end
end
