module Aero::Template
  class Token
    enum Kind
      String
      Number
      Bool
      Null
      Space
      Ident
      Operator
      Eol
    end

    property start : Int32
    property stop : Int32
    property kind : Kind
    property value : String?

    def initialize(@start)
      @stop = 0
      @kind = :eol
    end

    def value! : String
      @value.not_nil!
    end
  end

  class Lexer
    OP_SYMBOLS = {'+', '-', '*', '/', '^', '%', '=', '!', '<', '>'}

    property reader : Char::Reader
    property token : Token

    def initialize(input : String)
      @reader = Char::Reader.new input
      @token = uninitialized Token
    end

    def run : Array(Token)
      tokens = [] of Token

      loop do
        next_token
        tokens << @token
        break if @token.kind.eol?
      end

      tokens
    end

    def next_token : Nil
      @token = Token.new position

      case current_char
      when '\0'
        @token.kind = :eol
      when ' ', '\t'
        read_whitespace
      when '"', '\''
        read_string
      when '0'..'9'
        read_number
      when '_'
        if peek_char.ascii_alphanumeric?
          read_ident
        else
          raise SyntaxError.new("Unexpected token '_'", @token.start, @reader.pos)
        end
      when 'n'
        read_null_or_ident
      when 't', 'f'
        read_bool_or_ident
      when .ascii_alphanumeric?
        read_ident
      when .in?(OP_SYMBOLS)
        read_operator
      else
        raise SyntaxError.new("Unexpected token '#{current_char}'", @token.start, @reader.pos)
      end

      @token.stop = @reader.pos
    end

    def read_whitespace : Nil
      @token.kind = :space

      while current_char == ' ' || current_char == '\t'
        next_char
      end
    end

    def read_string : Nil
      @token.kind = :string
      @token.start += 1
      delim = current_char
      escaped = false

      next_char
      loop do
        case current_char
        when '\0'
          raise SyntaxError.new("Unexpected End-Of-Line", 0, 0)
        when '\\'
          escaped = peek_char == delim
        when delim
          if escaped
            escaped = false
          else
            break
          end
        end

        next_char
      end

      @token.value = string[@token.start..position - 1]
      next_char
    end

    def read_number : Nil
      @token.kind = :number

      while current_char.ascii_number? || current_char == '.'
        next_char
      end

      @token.value = string[@token.start..position - 1]
    end

    def read_ident : Nil
      @token.kind = :ident

      while current_char.ascii_alphanumeric? || current_char.in?('_', '.')
        next_char
      end

      @token.value = string[@token.start..position - 1]
    end

    def read_null_or_ident : Nil
      if next_char == 'u' && next_char == 'l' && next_char == 'l'
        @token.kind = :null
        next_char
      else
        read_ident
      end
    end

    def read_bool_or_ident : Nil
      if current_char == 't'
        if next_char == 'r' && next_char == 'u' && next_char == 'e'
          @token.kind = :bool
          @token.value = "true"
          next_char
        else
          read_ident
        end
      else
        if next_char == 'a' && next_char == 'l' && next_char == 's' && next_char == 'e'
          @token.kind = :bool
          @token.value = "false"
          next_char
        else
          read_ident
        end
      end
    end

    def read_operator : Nil
      @token.kind = :operator

      while current_char.in?(OP_SYMBOLS)
        next_char
      end

      @token.value = string[@token.start..position - 1]
    end

    def current_char : Char
      @reader.current_char
    end

    def peek_char : Char
      @reader.peek_next_char
    end

    def next_char : Char
      @reader.next_char
    end

    def string : String
      @reader.string
    end

    def position : Int32
      @reader.pos
    end
  end
end
