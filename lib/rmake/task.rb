# frozen_string_literal: true

require_relative './env_helper'

# impl build task for target
class Task
  include EnvHelper

  def initialize(env, cmd)
    @env = env
    @echo = nil
    @_cmd = cmd
  end

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

  def _render_cmd
    cmd = @_cmd
    vars = cmd.scan(/\$\(([^)]*)\)/).flatten
    vars.each do |var_name|
      val = @env.fetch(var_name, '')
      cmd = cmd.sub(/\$\(([^)]*)\)/, val)
    end
    cmd
  end

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