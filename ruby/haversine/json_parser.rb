# frozen_string_literal: true

# responsible for tokenizing json
class JsonLexer
  attr_reader :line_number

  def initialize(source_file)
    @source_file = source_file
    @line = ''
    @line_number = 0
  end

  def lex
    if /^\s+/ =~ @line
      @line = ::Regexp.last_match.post_match
    end

    while @line.empty?
      @line = @source_file.gets
      return :eof if @line.nil?

      @line_number += 1

      if /\A\s+/ =~ @line
        @line = ::Regexp.last_match.post_match
      end
    end
    case @line
    when /\A:/
      yield ::Regexp.last_match(0)
      token = :colon
    when /\A\[/
      yield ::Regexp.last_match(0)
      token = :lbracket
    when /\A\]/
      yield ::Regexp.last_match(0)
      token = :rbracket
    when /\A\{/
      yield ::Regexp.last_match(0)
      token = :lbra
    when /\A\}/
      yield ::Regexp.last_match(0)
      token = :rbra
    when /\A,/
      yield ::Regexp.last_match(0)
      token = :comma
    when /"([^"]*)"/
      yield ::Regexp.last_match(1)
      token = :string
    when /\A[+-]?\d+\.\d+([eE][-+]?[0-9]+)?/
      yield ::Regexp.last_match(0)
      token = :float
    when /\A[+-]?\d+/
      yield ::Regexp.last_match(0)
      token = :int
    when /\Afalse/
      yield ::Regexp.last_match(0)
      token = :false
    when /\Atrue/
      yield ::Regexp.last_match(0)
      token = :true
    when /\Anull/
      yield ::Regexp.last_match(0)
      token = :null
    when /\A\s/
      # ignore
      token = :whitespace
    when /\A\S/
      # ignore
      token = :other
    end
    @line = ::Regexp.last_match.post_match
    token
  end
end

class JsonParser
  def initialize(lexer)
    @lexer = lexer
    @token = @lexer.lex { |l| @lexeme = l }
  end

  def parse
    json_object
  end

  def check_token(expected)
    if @token == expected
      @token = @lexer.lex { |l| @lexeme = l }
    else
      puts "Expected #{expected} but found #{@lexeme}"
      exit(1)
    end
  end

  def json_object
    case @token
    when :lbra
      check_token(:lbra)
      result = {}
      while @token == :string
        key = @lexeme
        check_token(:string)
        check_token(:colon)
        value = json_value
        result[key] = value
        check_token(:comma) if @token == :comma
      end
      check_token(:rbra)
    else
      puts 'Syntax error: { is expected'
      exit(1)
    end
    result
  end

  def json_value
    case @token
    when :string
      result = @lexeme
      check_token(:string)
    when :int
      result = @lexeme.to_i
      check_token(:int)
    when :float
      result = @lexeme.to_f
      check_token(:float)
    when :true
      result = true
      check_token(:true)
    when :false
      result = false
      check_token(:false)
    when :null
      result = nil
      check_token(:null)
    when :lbra
      result = json_object
    when :lbracket
      result = json_array
    else
      puts "Syntax error: Unexpected token: #{@lexeme}"
      exit(1)
    end
    result
  end

  def json_array
    case @token
    when :lbracket
      check_token(:lbracket)
      result = []
      while @token != :rbracket
        value = json_value
        result << value
        check_token(:comma) if @token == :comma
      end
      check_token(:rbracket)
    else
      puts 'Syntax error: [ is expected'
      exit(1)
    end
    result
  end
end
