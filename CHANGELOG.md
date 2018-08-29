# CHANGELOG for activerecord-shard_for

## 0.6.1

- Allow settings `thread_pool_base_size` and command executor. [#18](https://github.com/yuemori/activerecord-shard_for/pull/18)
- Bump up supporeted rails versions. [#19](https://github.com/yuemori/activerecord-shard_for/pull/19)
  - Add rails 5.2

## 0.6.0

- Support same connection to connect for same shard. [#15](https://github.com/yuemori/activerecord-shard_for/pull/15)
- Drop rails4 support

## 0.5.0

- Support Single Table Inheritance. [#14](https://github.com/yuemori/activerecord-shard_for/pull/14)

## 0.4.1

- Fix defined_enums is empty. [#11](https://github.com/yuemori/activerecord-shard_for/pull/11)

## 0.4.0

- Distkey support to instance method. [#9](https://github.com/yuemori/activerecord-shard_for/pull/9)

## 0.3.0

- Add using syntax. [#8](https://github.com/yuemori/activerecord-shard_for/pull/8)

## 0.2.1

- Fix raise MissingDistkeyAttribute before callback. [#6](https://github.com/yuemori/activerecord-shard_for/pull/6)
- Fix rake tasks not load in rails. [#3](https://github.com/yuemori/activerecord-shard_for/pull/3)
- Modify raise KeyError when not registered connection_key call  [#7](https://github.com/yuemori/activerecord-shard_for/pull/7)

## 0.2.0

- Enable Range support for cluster key
- Add built-in connection router of DistkeyRouter

## 0.1.2

- Fix `cluster_router` is now working
