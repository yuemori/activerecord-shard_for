base = { 'adapter' => 'sqlite3' }
ActiveRecord::Base.configurations = {
  'test_user_001' => base.merge('database' => 'user_001.sqlite3'),
  'test_user_002' => base.merge('database' => 'user_002.sqlite3'),
  'test_user_003' => base.merge('database' => 'user_003.sqlite3'),
  'test_user_004' => base.merge('database' => 'user_004.sqlite3'),
  'test_user_readonly_001' => base.merge('database' => 'user_001.sqlite3'),
  'test_user_readonly_002' => base.merge('database' => 'user_002.sqlite3'),
  'test_user_readonly_003' => base.merge('database' => 'user_003.sqlite3'),
  'test_user_readonly_004' => base.merge('database' => 'user_004.sqlite3'),
  'test' => base.merge('database' => 'default.sqlite3')
}
ActiveRecord::Base.establish_connection(:test)

ActiveRecord::ShardFor.configure do |config|
  config.define_cluster(:user) do |cluster|
    cluster.register(0, :test_user_001)
    cluster.register(1, :test_user_002)
    cluster.register(2, :test_user_003)
    cluster.register(3, :test_user_004)
  end

  config.define_cluster(:user_readonly) do |cluster|
    cluster.register(0, :test_user_readonly_001)
    cluster.register(1, :test_user_readonly_002)
    cluster.register(2, :test_user_readonly_003)
    cluster.register(3, :test_user_readonly_004)
  end
end

class User < ActiveRecord::Base
  include ActiveRecord::ShardFor::Model
  use_cluster :user, :hash_modulo
  def_distkey :email
  replicates_with slave: :UserReadonly
end

class UserReadonly < ActiveRecord::Base
  self.table_name = 'users'
  include ActiveRecord::ShardFor::Model
  use_cluster :user_readonly, :hash_modulo
  def_distkey :email
  replicates_with master: :User
end
