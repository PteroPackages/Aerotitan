module Aero::Query
  class Token
    enum Kind
      EOL
      Ident
      Illegal

      Equal
      Plus

      Number
      String
      Boolean
      Null

      # And
      # Or
      # Contains
      # Missing
    end

    property start : Int32
    property stop : Int32
    property kind : Kind
    @value : String?

    def initialize(@start)
      @stop = 0
      @kind = :eol
    end

    def value : String
      @value.as(String)
    end
  end

  class Lexer
    @reader : Char::Reader
    @input : String

    def initialize(@input : String)
      @reader = Char::Reader.new input
    end

    def run : Array(Token)
      tokens = [] of Token

      loop do
        token = next_token
        tokens << token
        break if token.kind.eol?
      end

      tokens
    end

    private def next_token : Token
      token = Token.new current_pos

      case current_char
      when '\0'
        # skip
      when ' ', '\t'
        return next_token
      when '\r', '\n'
        token.kind = :illegal
        token.value = "unexpected carriage return or newline"
      when '='
        token.kind = :equal
      when '+'
        token.kind = :plus
      when '"', '\''
        delim = current_char

        loop do
          case next_char
          when '\0'
            token.kind = :illegal
            token.value = "unterminated quote string"
            break
          when '\r', '\n'
            token.kind = :illegal
            token.value = "unexpected carriage return or newline"
            break
          when delim
            next_char
            break
          end
        end

        token.kind = :string
      end

      token.stop = current_pos

      token
    end

    private def current_char : Char
      @reader.current_char
    end

    private def next_char : Char
      @reader.next_char
    end

    private def current_pos : Int32
      @reader.pos
    end
  end
end
