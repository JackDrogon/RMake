# frozen_string_literal: true

# Env for rmake runtime env storage
class Env
  def initialize(table = {}, parent = nil)
    raise 'table is not Hash' if @table.is_a?(Hash)

    @table = table

    raise 'parent is not nil or Env' if !parent.nil? && !parent.is_a?(Env)

    @parent = parent
  end

  def include?(key)
    @table.include?(key) || @parent&.include?(key)
  end

  def fetch(key, default_value)
    if include?(key)
      self[key]
    else
      default_value
    end
  end

  def delete(key)
    @table.delete(key)
    @parent&.delete(key)
  end

  def [](key)
    @table[key] || @parent&.[](key)
  end

  def []=(key, value)
    if @table.include?(key)
      @table[key] = value
    elsif @parent&.include?(key)
      @parent[key] = value
    else
      @table[key] = value
    end
  end
end
