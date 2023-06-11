# frozen_string_literal: true

# Token struct with type and data attributes
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

  # Returns the next token from the input stream
  # Returns a Token object with type and data attributes
  # Returns a Token object with type EOF and data nil if there are no more tokens
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
