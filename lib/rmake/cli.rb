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
  # @param options [Hash] The options for the CLI.
  # @option options [String] :rmakefile The path to the RMakefile.
  # @option options [String] :target The name of the target to build.
  # @return [void]
  def initialize(env, options)
    @options = options
    @env = env
    rmakefile = options[:rmakefile]
    lexer = Lexer.new(env, rmakefile)
    @parser = Parser.new(env, lexer)

    @target_name = options[:target]
    @target_map = {}

    _parse
  end

  # Builds the target specified by @target_name instance variable.
  # If @target_name is not found in @target_map, it prints an error message and exits with status code 1.
  # Otherwise, it calls build_target method to build the target.
  def build
    # TODO: check target not found
    if not @target_name.nil? and not @target_map.key?(@target_name)
      puts "target #{@target_name} not found"
      exit(1)
    end

    v { puts '-------------------------' }
    _build_target
  end

  # Returns an array of all target names.
  #
  # @return [Array<String>] An array of all target names.
  def list_targets
    @target_map.keys
  end

  # Runs the CLI command. If the `list` option is set to true, it lists all available targets. Otherwise, it builds the target specified in the command line arguments.
  #
  # Returns nothing.
  def run
    if @options[:list]
      puts '================================='
      puts '----- list targets -----'
      puts list_targets
      puts '================================='
    else
      build
    end
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

  # Builds the target specified by @target_name, if it exists in @target_map.
  # Sets the ENV_INDENT environment variable to 0 before building the target.
  # Deletes the ENV_INDENT environment variable after building the target.
  # Returns nothing.
  def _build_target
    @env[ENV_INDENT] = 0
    target = @target_map[@target_name]
    target&.build
    @env.delete(ENV_INDENT)
  end
end
