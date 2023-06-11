# frozen_string_literal: true

require_relative './env_helper'

# impl build task for target
class Task
  include EnvHelper

  # Initializes a new instance of Task class.
  #
  # @param env [Hash] The environment variables.
  # @param cmd [String] The command to execute.
  def initialize(env, cmd)
    @env = env
    @echo = nil
    @_cmd = cmd
  end

  # Builds the task.
  #
  # @return [String] The command to execute if it starts with '#', otherwise the system command.
  def build
    cmd = _render_cmd
    _echo { puts "#{indent_space} --> #{cmd}" }

    if cmd.strip.start_with? '#'
      cmd
    else
      system cmd
    end
  end

  private

  # Renders the command by replacing the environment variables with their values.
  #
  # @return [String] The rendered command.
  def _render_cmd
    cmd = @_cmd
    vars = cmd.scan(/\$\(([^)]*)\)/).flatten
    vars.each do |var_name|
      val = @env.fetch(var_name, '')
      cmd = cmd.sub(/\$\(([^)]*)\)/, val)
    end
    cmd
  end

  # Echoes the command if it starts with '@'.
  #
  # @return [void]
  def _echo
    if @echo.nil?
      # nil run first
      @echo = true
      if @_cmd.start_with?('@')
        @echo = false
        @_cmd[0] = ''
      end
    end

    yield if @echo && block_given?
  end
end
