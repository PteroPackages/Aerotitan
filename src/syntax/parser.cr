module Aerotitan::Syntax
  enum Operators
    Eq
    Neq
    Lt
    Lte
    Gt
    Gte

    def self.from(value : String)
      case value
      when "==" then Operators::Eq
      when "!=" then Operators::Neq
      when "<"  then Operators::Lt
      when "<=" then Operators::Lte
      when ">"  then Operators::Gt
      when ">=" then Operators::Gte
      else
        raise "invalid operator"
      end
    end

    def to_s : String
      case self
      in Operators::Eq  then "=="
      in Operators::Neq then "!="
      in Operators::Lt  then "<"
      in Operators::Lte then "<="
      in Operators::Gt  then ">"
      in Operators::Gte then ">="
      end
    end
  end

  class Parser
    VALID_OPERATORS = {"==", "!=", "<", "<=", ">", ">="}

    property tokens : Array(Token)
    property nodes : Array(Node)
    property pos : Int32

    def initialize(@tokens, @pos = -1)
      @nodes = [] of Node
    end

    def run : Array(Node)
      loop do
        @pos += 1
        if token = @tokens[@pos]?
          next if token.kind.space?
          break if token.kind.eol?
          @nodes << parse_node token
        else
          break
        end
      end

      @nodes
    end

    def parse_node(token : Token) : Node
      node : Node

      case token.kind
      in Kind::Number
        if token.value!.ends_with? '.'
          raise SyntaxError.new("Invalid number literal", token.start, token.stop)
        end

        node = NumberLiteral.new token.start, token.stop, token.value!
      in Kind::String
        node = StringLiteral.new token.start, token.stop, token.value!
      in Kind::Bool
        node = BoolLiteral.new token.start, token.stop, token.value!
      in Kind::Null
        node = NullLiteral.new token.start, token.stop
      in Kind::Space
        return parse_node @tokens[@pos += 1]
      in Kind::Ident
        if token.value!.ends_with?('.') || token.value!.ends_with?('_')
          raise SyntaxError.new("Invalid field name", token.start, token.stop)
        end

        split = token.value!.split '.'
        raise "Invalid field name" if split.any? &.blank?

        node = Field.new token.start, token.stop, token.value!
      in Kind::Operator
        unless token.value!.in?(Parser::VALID_OPERATORS)
          raise SyntaxError.new("Invalid operator '#{token.value!}'", token.start, token.stop)
        end

        if left = previous_node
          unless left.is_a?(Literal)
            raise SyntaxError.new("Cannot use type #{left} for left-side expression", token.start, token.stop)
          end

          right = parse_node @tokens[@pos + 1]
          unless right.is_a?(Literal)
            raise SyntaxError.new("Cannot use type #{right} for right-side expression", token.start, token.stop)
          end

          node = Operator.new token.start, token.stop, Operators.from(token.value!), left, right
        else
          raise SyntaxError.new("Missing left-side expression for operator", token.start, token.stop)
        end
      in Kind::Eol
        raise SyntaxError.new("Unexpected End-Of-Line", token.start, token.stop)
      end

      node
    end

    private def previous_node : Node?
      @nodes.last?
    end
  end
end