# frozen_string_literal: true
require 'spec_helper'

describe ActiveRecord::ShardFor do
  it 'has a version number' do
    expect(ActiveRecord::ShardFor::VERSION).not_to be nil
  end
end
