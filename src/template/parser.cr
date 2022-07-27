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
    in Kind::Number then NumberLiteral.new token
    in Kind::String then StringLiteral.new token
    in Kind::Bool   then BoolLiteral.new token
    in Kind::Null   then NullLiteral.new token
    in Kind::Access then AccessNode.new token
    in Kind::Field  then FieldNode.new token
    in Kind::OpEq   then EqualsOp.new token
    in Kind::Space  then Nop.new token
    in Kind::Eof    then Nop.new token
    end
  end
end
