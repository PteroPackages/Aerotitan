require "./token"

class Lexer
  property data   : Array(Char)
  property token  : Token
  property pos    : Int32
  property max    : Int32

  def initialize(input : String)
    @data = input.chars
    @token = uninitialized Token
    @pos = 0
    @max = @data.size - 1
  end

  def run
    tokens = [] of Token
    loop do
      token = next_token
      tokens << token
      break if token.kind == Kind::Eol
    end

    tokens
  end

  def current : Char
    if c = @data[@pos]?
      c
    else
      '\0'
    end
  end

  def peek(count = 1) : Char
    if c = @data[@pos+count]?
      c
    else
      '\0'
    end
  end

  def next_token : Token
    @token = Token.new @pos

    case current
    when '\0'
      @token.kind = :eol
      @pos += 1
    when '.'
      @token.kind = :dot
      @pos += 1
    when ','
      @token.kind = :comma
      @pos += 1
    when ' ', '\t'
      skip_whitespace
    when '0'..'9'
      read_number
    when '"', '\''
      read_string
    when '('
      @token.kind = :left_paren
      @pos += 1
    when ')'
      @token.kind = :right_paren
      @pos += 1
    when '_'
      if peek.alphanumeric?
        read_ident
      else
        raise "unexpected token '_'"
      end
    when 'n'
      maybe_read_null
    when 't', 'f'
      maybe_read_bool
    when .ascii_alphanumeric?
      read_ident
    else
      raise "unexpected token '#{current}'"
    end

    @token.stop = @pos
    @token
  end

  def skip_whitespace : Nil
    @token.kind = :space

    while current == ' ' || current == '\t'
      @pos += 1
    end
  end

  def read_number : Nil
    @token.kind = :number

    while current.number?
      @pos += 1
    end

    @token.value = @data[@token.start..@pos].join
  end

  def read_string : Nil
    @token.kind = :string
    delim = current
    @pos += 1
    @token.start += 1
    escaped = false

    loop do
      case current
      when delim
        if escaped
          escaped = !escaped
        else
          break
        end
      when '\0'
        raise "unexpected eol"
      end

      @pos += 1
    end

    @token.value = @data[@token.start..@pos-1].join
    @pos += 1
  end

  def read_ident : Nil
    @token.kind = :ident

    while current.alphanumeric? || current == '_'
      @pos += 1
    end

    @token.value = @data[@token.start..@pos-1].join
  end

  def maybe_read_null : Nil
    if peek == 'u' && peek(2) == 'l' && peek(3) == 'l'
      @token.kind = :null
      @pos += 4
    else
      read_ident
    end
  end

  def maybe_read_bool : Nil
    case current
    when 't'
      if peek == 'r' && peek(2) == 'u' && peek(3) == 'e'
        @token.kind = :bool
        @token.value = "true"
        @pos += 4
      else
        read_ident
      end
    when 'f'
      if peek == 'a' && peek(2) == 'l' && peek(3) == 's' && peek(4) == 'e'
        @token.kind = :bool
        @token.value = "false"
        @pos += 5
      else
        read_ident
      end
    else
      read_ident
    end
  end
end
