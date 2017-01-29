require 'spec_helper'

# See spec/models.rb about model definitions
RSpec.describe 'STI' do
  before do
    CPU.put!(name: 'cpu1', cpu_frequency: 3.2)
    Memory.put!(name: 'memory1', memory_capacity: 8)
  end

  it 'supports single table inheritance to work' do
    expect { CPU.put!(name: 'cpu1') }.to raise_error ActiveRecord::RecordInvalid
    expect { Memory.put!(name: 'memory1') }.to raise_error ActiveRecord::RecordInvalid

    cpu = CPU.get('cpu1')
    memory = Memory.get('memory1')

    expect(cpu).to be_present
    expect(cpu).to be_respond_to :frequency
    expect(cpu).not_to be_respond_to :capacity
    expect(cpu.frequency).to eq '3.2GHz'
    expect(memory).to be_present
    expect(memory).to be_respond_to :capacity
    expect(memory).not_to be_respond_to :frequency
    expect(memory.capacity).to eq '8GB'

    product_counts = Product.all_shards.flat_map(&:count).compact
    expect(product_counts.sum).to eq 2
  end
end
