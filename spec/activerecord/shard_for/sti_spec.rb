require 'spec_helper'

# See spec/models.rb about model definitions
RSpec.describe 'STI' do
  before do
    CPU.put!(name: 'cpu1')
    Memory.put!(name: 'memory1')
  end

  it 'supports single table inheritance to work' do
    cpu = CPU.get!('cpu1')
    memory = Memory.get!('memory1')
    expect(cpu).to be_present
    expect(memory).to be_present

    products = Product.all_shards.flat_map { |m| m.all }.compact
    expect(products.count).to eq 2
  end
end
