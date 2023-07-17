module Aero::Query
  class Token
    enum Kind
      EOL
      Ident
      Illegal

      Equal
      NotEqual
      Plus

      Number
      String
      Boolean
      Null

      And
      Or
      Contains
      Missing
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

    def value=(@value)
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
        return token
      when ' ', '\t'
        next_char
        return next_token
      when '\r', '\n'
        token.kind = :illegal
        token.value = "unexpected carriage return or newline"
      when '='
        token.kind = :equal
      when '!'
        if next_char == '='
          token.kind = :not_equal
          next_char
        else
          token.kind = :illegal
          token.value = "unexpected character '!' (usually used for not-equal)"
          return token
        end
      when '+'
        token.kind = :plus
      when '"', '\''
        delim = current_char

        loop do
          case next_char
          when '\0'
            token.kind = :illegal
            token.value = "unterminated quote string"
            return token
          when '\r', '\n'
            token.kind = :illegal
            token.value = "unexpected carriage return or newline"
            return token
          when delim
            break
          end
        end

        token.kind = :string
        token.value = @input[token.start+1..current_pos-1]
      when .ascii_letter?
        loop do
          case next_char
          when '\r', '\n'
            token.kind = :illegal
            token.value = "unexpected carriage return or newline"
            return token
          when .ascii_letter?, '.', '_'
            next
          else
            break
          end
        end

        case value = @input[token.start..current_pos-1]
        when "null"
          token.kind = :null
        when "and"
          token.kind = :and
        when "or"
          token.kind = :or
        when "contains"
          token.kind = :contains
        when "missing"
          token.kind = :missing
        else
          token.kind = :ident
          token.value = value
        end
      when .ascii_number?
        loop do
          case next_char
          when '\r', '\n'
            token.kind = :illegal
            token.value = "unexpected carriage return or newline"
            return token
          when .ascii_number?, '.', '_'
            next
          else
            break
          end
        end

        token.kind = :number
        token.value = @input[token.start..current_pos-1]
      else
        token.kind = :illegal
        token.value = "illegal character #{current_char.inspect}"
      end

      token.stop = current_pos
      next_char unless current_char == '\0'

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
