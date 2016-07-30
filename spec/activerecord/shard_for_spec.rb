# frozen_string_literal: true
require 'spec_helper'

describe Activerecord::ShardFor do
  it 'has a version number' do
    expect(Activerecord::ShardFor::VERSION).not_to be nil
  end
end
