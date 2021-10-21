# frozen_string_literal: true

Token = Struct.new(:type, :data)

# Makefile lexer impl
class Lexer
  ASSIGNMENT = 1
  DEPENDENCY = 2
  TASK = 3
  EOF = 4

  def initialize(env, rmakefile)
    @env = env
    @rmakefile = rmakefile
    @data = nil # buffer with lines
  end

  # nil is empty
  def next
    @data = File.readlines(@rmakefile) if @data.nil?

    line = @data.shift&.rstrip!
    if line.nil?
      Token.new(EOF, nil)
    elsif line.empty?
      self.next
    elsif line.start_with?("\t")
      # TASK
      line.lstrip!
      Token.new(TASK, line)
    elsif line.include?('=')
      Token.new(ASSIGNMENT, line)
    else
      # DEPENDENCY
      Token.new(DEPENDENCY, line)
    end
  end
end
