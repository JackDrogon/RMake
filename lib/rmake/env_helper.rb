# frozen_string_literal: true

# EnvHelper for some helper function moudle mixin for Env
module EnvHelper
  def v
    yield if _verbose >= 1 && block_given?
  end

  def vv
    yield if _verbose >= 2 && block_given?
  end

  def indent_space
    '  ' * @env[ENV_INDENT]
  end

  def indent_monitor
    @env[ENV_INDENT] += 1
    yield if block_given?
    @env[ENV_INDENT] -= 1
  end

  private

  def _verbose
    @env.fetch('VERBOSE', 0).to_i
  end
end
