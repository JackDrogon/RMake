# frozen_string_literal: true

require_relative './env'
require_relative './env_helper'
require_relative './lexer'
require_relative './parser'
require_relative './task'
require_relative './target'

# RMake entrance class
class CLI
  include EnvHelper

  def initialize(env, rmakefile, target_name)
    @env = env
    lexer = Lexer.new(env, rmakefile)
    @parser = Parser.new(env, lexer)

    @target_name = target_name
    @target_map = {}

    _parse
  end

  def build
    @env[ENV_INDENT] = 0
    target = @target_map[@target_name]
    target&.build
    @env.delete(ENV_INDENT)
  end

  def list_targets
    @target_map.keys
  end

  def run
    # TODO: check target not found
    unless @target_name
      puts "target #{@target_name} not found"
      exit(1)
    end

    v { puts '-------------------------' }
    build
  end

  private

  def _parse
    @parser.parse

    all_deps = @parser.all_deps
    tasks = @parser.tasks

    @target_name ||= @parser.first_target
    all_deps.each do |name, deps|
      target = Target.new(@env, name, deps, tasks[name], @target_map)
      @target_map[name] = target
    end
    vv { pp @target_name }
    vv { pp all_deps }
    vv { pp tasks }
    vv { pp @env }
  end
end
