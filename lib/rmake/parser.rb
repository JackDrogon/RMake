# frozen_string_literal: true

require_relative './env'
require_relative './env_helper'
require_relative './lexer'
require_relative './task'

# Parser to deal token by lexer
class Parser
  include EnvHelper

  attr_reader :first_target, :all_deps, :tasks

  def initialize(env, lexer)
    @env = env
    @lexer = lexer
    @first_target = nil
    @all_deps = {}
    @tasks = {}
  end

  def parse
    current_target = nil

    loop do
      token = @lexer.next
      case token.type
      when Lexer::DEPENDENCY
        # "clean:" => ["clean"]
        # "total: 1.o 2.c 2.h 1.h" => ["total", "1.o 2.c 2.h 1.h"]
        # TODO: check end_with? ':'
        rules = token.data.split(':').map(&:strip)
        target_name = rules[0]
        @first_target ||= target_name
        current_target = target_name
        target_deps = [] # default for clean: just no deps
        target_deps = rules[1].split.map(&:strip) unless rules.length == 1

        (@all_deps[current_target] ||= []).concat(target_deps)
      when Lexer::TASK
        # ["gcc 1.o 2.c -o total"]
        unless current_target
          puts 'found rule before target'
          exit(1)
        end
        (@tasks[current_target] ||= []) << token.data
      when Lexer::ASSIGNMENT
        # TODO: check error, such as "a="
        var_name, var_val = token.data.split('=').map(&:strip)
        @env[var_name] = var_val
        vv { puts "assign #{var_name} = #{var_val}" }
      when Lexer::EOF
        break
      end
    end
  end
end
