require_relative '../lib/rmake/env'
require 'minitest/autorun'

class EnvTest < Minitest::Test
  def setup
    @env = Env.new({ 'foo' => 'bar' })
  end

  def test_include?
    assert @env.include?('foo')
    refute @env.include?('baz')
  end

  def test_fetch
    assert_equal 'bar', @env.fetch('foo', 'default')
    assert_equal 'default', @env.fetch('baz', 'default')
  end

  def test_delete
    assert_equal 'bar', @env.delete('foo')
    refute @env.include?('foo')
    assert_nil @env.delete('baz')
  end

  def test_get
    assert_equal 'bar', @env['foo']
    assert_nil @env['baz']
  end

  def test_set
    @env['foo'] = 'baz'
    assert_equal 'baz', @env['foo']

    @env['baz'] = 'qux'
    assert_equal 'qux', @env['baz']
  end

  def test_parent
    parent = Env.new({ 'foo' => 'baz' })
    env = Env.new({ 'bar' => 'qux' }, parent)

    assert_equal 'baz', env['foo']
    assert_equal 'qux', env['bar']
  end

  def test_invalid_table
    assert_raises(RuntimeError) { Env.new('foo') }
  end

  def test_invalid_parent
    assert_raises(RuntimeError) { Env.new({}, 'foo') }
  end
end