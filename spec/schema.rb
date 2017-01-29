ActiveRecord::Schema.define(version: 0) do
  create_table 'users', force: :cascade do |t|
    t.string   'name',         null: false
    t.string   'email',        null: false
    t.integer  'age'
    t.datetime 'created_at',   null: false
    t.datetime 'updated_at',   null: false
  end

  create_table 'characters', force: :cascade do |t|
    t.string   'name',         null: false
    t.integer  'shard_no'
    t.datetime 'created_at',   null: false
    t.datetime 'updated_at',   null: false
  end

  create_table 'products', force: :cascade do |t|
    t.string   'name',       null: false
    t.string   'type',       null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end
end
