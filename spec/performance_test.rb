require 'pry'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'activerecord/shard_for'

require File.expand_path('../models', __FILE__)

def measure(n, &block)
  prev = Time.now
  n.times { block.call }
  Time.now - prev
end

n = 10 ** 3
s = SecureRandom.hex(32)
elasped_time = measure(n) { User.shard_for(s) }

puts '=== Performance test result ==='
puts "#{n} times of `User.shard_for` tooks #{elasped_time} sec"
puts '===        End result       ==='

if elasped_time >= 0.1
  exit 1
else
  exit
end