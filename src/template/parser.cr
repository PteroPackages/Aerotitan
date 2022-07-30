require "./node"
require "./token"

class Parser
  property tokens : Array(Token)
  property pos    : Int32

  def initialize(@tokens)
    @pos = 0
  end

  def next_token : Token
    @tokens[@pos += 1]
  end

  def expect_token(*kinds : Kind) : Token
    t = next_token
    raise_expected_token(kinds.join(" or "), t.kind) unless kinds.includes? t.kind
    t
  end

  def run : Array(Node)
    nodes = [] of Node

    loop do
      if token = @tokens[@pos]?
        case token.kind
        when Kind::Ident  then nodes << parse_ident token
        when Kind::Eol    then break
        end
      else
        break
      end
    end

    nodes
  end

  def raise_unexpected_token(kind : Kind) : NoReturn
    raise "unexpectecd token '#{kind}'"
  end

  def raise_expected_token(expect : Kind | String, got : Kind) : NoReturn
    raise "expected token #{expect}; got #{got}"
  end

  def parse_ident(token : Token) : Node
    names = [token.value.not_nil!]
    stop = 0

    loop do
      t = next_token
      case t.kind
      when Kind::Dot
        next
      when Kind::Comma
        stop = @tokens[@pos -= 1].stop
        break
      when Kind::Ident
        names << t.value.not_nil!
      when Kind::LeftParen
        return parse_func t.start, names
      else
        raise_unexpected_token t.kind
      end
    end

    FieldNode.new token.start, stop, names
  end

  def parse_func(start : Int32, names : Array(String)) : Node
    if names.size > 1
      raise "invalid function name '#{names.join('.')}'"
    end

    args = [] of Node
    stop = 0

    loop do
      t = next_token
      case t.kind
      when Kind::Number
        args << NumberLiteral.new t.start, t.stop, t.value.not_nil!
      when Kind::String
        args << StringLiteral.new t.start, t.stop, t.value.not_nil!
      when Kind::Bool
        args << BoolLiteral.new t.start, t.stop, t.value.not_nil!
      when Kind::Null
        args << NullLiteral.new t.start, t.stop
      when Kind::Space
        next
      when Kind::Ident
        args << parse_ident t
        _ = expect_token Kind::Dot, Kind::Comma
        next
      when Kind::RightParen
        stop = t.stop
        break
      else
        raise_unexpected_token t.kind
      end

      ex = expect_token Kind::Comma, Kind::RightParen
      if ex.kind == Kind::RightParen
        stop = ex.stop
        break
      end
    end

    @pos += 1
    FuncNode.new start, stop, names[0], args
  end
end
