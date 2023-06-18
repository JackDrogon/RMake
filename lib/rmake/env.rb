# frozen_string_literal: true

# Env for rmake runtime env storage
class Env
  # Initializes a new instance of Env class.
  #
  # @param table [Hash] The hash table to store the environment variables.
  # @param parent [Env, nil] The parent environment to inherit variables from.
  # @raise [RuntimeError] If table is not a Hash.
  # @raise [RuntimeError] If parent is not nil or an instance of Env.
  def initialize(table = {}, parent = nil)
    raise 'table is not Hash' if !table.is_a?(Hash)

    @table = table

    raise 'parent is not nil or Env' if !parent.nil? && !parent.is_a?(Env)

    @parent = parent
  end

  # Checks if the given key is present in the environment.
  #
  # @param key [Object] The key to check.
  # @return [Boolean] Returns true if the key is present in the environment, otherwise false.
  def include?(key)
    @table.include?(key) || @parent&.include?(key)
  end

  # Fetches the value of the given key from the environment.
  #
  # @param key [Object] The key to fetch the value for.
  # @param default_value [Object] The default value to return if the key is not present in the environment.
  # @return [Object] Returns the value of the key if present in the environment, otherwise the default value.
  def fetch(key, default_value)
    if include?(key)
      self[key]
    else
      default_value
    end
  end

  # Deletes the given key from the environment.
  # 
  # if the key is present in the table, only delete it from the table.
  # otherwise, delete it from the parent.
  #
  # @param key [Object] The key to delete.
  # @return [Object, nil] Returns the value of the deleted key if present in the environment, otherwise nil.
  def delete(key)
    value = @table.delete(key)

    if value
      value
    else
      @parent&.delete(key)
    end
  end

  # Gets the value of the given key from the environment.
  #
  # @param key [Object] The key to get the value for.
  # @return [Object, nil] Returns the value of the key if present in the environment, otherwise nil.
  def [](key)
    @table[key] || @parent&.[](key)
  end

  # Sets the value of the given key in the environment.
  #
  # @param key [Object] The key to set the value for.
  # @param value [Object] The value to set for the key.
  # @return [Object] Returns the value that was set for the key.
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
