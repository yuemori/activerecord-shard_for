require 'spec_helper'

RSpec.describe ActiveRecord::ShardFor::ClusterRouter do
  let(:router) { described_class.new(cluster_config) }
  let(:cluster_config) { ActiveRecord::ShardFor.config.fetch_cluster_config(:user) }

  describe '#fetch_connection_name' do
    subject { router.fetch_connection_name(0) }
    before { expect(router).to receive(:route).with(0).and_return(0) }

    it { is_expected.to eq :test_user_001 }
  end
end
