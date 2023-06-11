# frozen_string_literal: true

# Makefile build target
class Target
  include EnvHelper

  attr_reader :name, :dependencies

  # Initializes a new instance of Target class.
  #
  # @param env [Env] The environment object.
  # @param name [String] The name of the target.
  # @param dependencies [Array<String>] The list of dependencies.
  # @param cmds [Array<String>] The list of commands to execute.
  # @param target_map [Hash<String, Target>] The hash map of targets.
  def initialize(env, name, dependencies, cmds, target_map)
    @env = env
    @name = name
    @dependencies = dependencies
    @tasks = (cmds || []).map { |cmd| Task.new(env, cmd) }
    @target_map = target_map
    @need_rebuild = nil
  end

  # Determines whether the target needs to be rebuilt.
  #
  # @return [Boolean] True if the target needs to be rebuilt, otherwise false.
  def rebuild?
    @need_rebuild = _rebuild? if @need_rebuild.nil?
    @need_rebuild
  end

  # Builds the target.
  def build
    return unless rebuild?

    v { puts "#{indent_space}Building target #{@name}" }

    build_all_dependencies
    @tasks.each(&:build)
    @need_rebuild = false
  end

  private

  # Determines whether the target needs to be rebuilt.
  #
  # @return [Boolean] True if the target needs to be rebuilt, otherwise false.
  def _rebuild?
    return true unless File.exist?(@name)

    @dependencies.any? do |dependency|
      # PHONY task
      return true unless File.exist?(dependency)

      target = @target_map[dependency]
      # check target is newer than dep
      if target.nil?
        # File task
        File.mtime(@name) < File.mtime(dependency)
      elsif target.rebuild?
        true
      else
        File.mtime(@name) < File.mtime(target.name)
      end
    end
  end

  # Builds all dependencies of the target.
  def build_all_dependencies
    indent_monitor do
      @dependencies.each do |dependency|
        target = @target_map[dependency]
        target&.build
      end
    end
  end
end
