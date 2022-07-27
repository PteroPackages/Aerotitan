require "./node"
require "./token"

class Parser
  property tokens : Array(Token)
  property pos    : Int32

  def initialize(@tokens)
    @pos = 0
  end

  def run : Array(Node)
    nodes = [] of Node

    loop do
      if token = @tokens[@pos]?
        node = parse_statement token
        unless node.is_a? Nop
          nodes << node
        end
        @pos += 1
      else
        break
      end
    end

    nodes
  end

  def parse_statement(token : Token) : Node
    case token.kind
    in Kind::Number then NumberLiteral.new(token.start, token.end, token.value.not_nil!)
    in Kind::String then StringLiteral.new(token.start, token.end, token.value.not_nil!)
    in Kind::Bool   then BoolLiteral.new(token.start, token.end, token.value.not_nil!)
    in Kind::Null   then NullLiteral.new(token.start, token.end, token.value.not_nil!)
    in Kind::Access then AccessNode.new token.start, token.end
    in Kind::Field  then FieldNode.new token.start, token.end
    in Kind::OpEq   then EqualsOp.new token.start, token.end
    in Kind::Space  then Nop.new
    in Kind::Eof    then Nop.new
    end
  end
end
