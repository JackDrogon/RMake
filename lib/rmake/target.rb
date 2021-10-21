# frozen_string_literal: true

# Makefile build target
class Target
  include EnvHelper

  attr_reader :name, :deps

  def initialize(env, name, deps, cmds, target_map)
    @env = env
    @name = name
    @deps = deps
    @tasks = (cmds || []).map { |cmd| Task.new(env, cmd) }
    @target_map = target_map
    @need_rebuild = nil
  end

  def rebuild?
    @need_rebuild = _rebuild? if @need_rebuild.nil?
    @need_rebuild
  end

  def build
    return unless rebuild?

    v { puts "#{indent_space}Building target #{@name}" }

    _build_deps
    @tasks.each(&:build)
    @need_rebuild = false
  end

  private

  def _rebuild?
    return true unless File.exist?(@name)

    @deps.any? do |dep|
      # PHONY task
      return true unless File.exist?(dep)

      target = @target_map[dep]
      if target.nil?
        # File task
        File.mtime(@name) < File.mtime(dep)
      elsif target.rebuild?
        true
      else
        File.mtime(@name) < File.mtime(target.name)
      end
    end
  end

  def _build_deps
    incr_indent
    @deps.each do |dep|
      target = @target_map[dep]
      target&.build
    end
    decr_indent
  end
end
