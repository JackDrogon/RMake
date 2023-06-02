# frozen_string_literal: true

# EnvHelper is a module that provides helper functions for the Env class.
module EnvHelper
  # Executes the block if the verbose level is at least 1.
  def v
    yield if _verbose >= 1 && block_given?
  end

  # Executes the block if the verbose level is at least 2.
  def vv
    yield if _verbose >= 2 && block_given?
  end

  # Returns a string of spaces for indentation based on the ENV_INDENT value.
  def indent_space
    '  ' * @env[ENV_INDENT]
  end

  # Increases the ENV_INDENT value, executes the block, and then decreases the ENV_INDENT value.
  def indent_monitor
    @env[ENV_INDENT] += 1
    yield if block_given?
    @env[ENV_INDENT] -= 1
  end

  private

  # Returns the verbose level as an integer.
  def _verbose
    @env.fetch('VERBOSE', 0).to_i
  end
end
