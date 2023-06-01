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

  # Initializes a new instance of the CLI class.
  #
  # @param env [Hash] The environment variables.
  # @param rmakefile [String] The path to the RMakefile.
  # @param target_name [String] The name of the target to build.
  def initialize(env, rmakefile, target_name)
    @env = env
    lexer = Lexer.new(env, rmakefile)
    @parser = Parser.new(env, lexer)

    @target_name = target_name
    @target_map = {}

    _parse
  end

  # Builds the target specified in the constructor.
  #
  # @return [void]
  def build
    @env[ENV_INDENT] = 0
    target = @target_map[@target_name]
    target&.build
    @env.delete(ENV_INDENT)
  end

  # Returns an array of all target names.
  #
  # @return [Array<String>] An array of all target names.
  def list_targets
    @target_map.keys
  end

  # Runs the build process for the target specified in the constructor.
  #
  # @return [void]
  def run
    # TODO: check target not found
    if not @target_name.nil? and not @target_map.key?(@target_name)
      puts "target #{@target_name} not found"
      exit(1)
    end

    v { puts '-------------------------' }
    build
  end

  private

  # Parses the RMakefile and creates the target map.
  #
  # @return [void]
  def _parse
    @parser.parse

    all_dependencies = @parser.all_dependencies
    tasks = @parser.tasks

    @target_name ||= @parser.first_target
    all_dependencies.each do |name, dependencies|
      target = Target.new(@env, name, dependencies, tasks[name], @target_map)
      @target_map[name] = target
    end
    vv { pp @target_name }
    vv { pp all_dependencies }
    vv { pp tasks }
    vv { pp @env }
  end
end
