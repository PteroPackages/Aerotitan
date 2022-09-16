module Aerotitan::Syntax
  class Parser
    VALID_OPERATORS = {"+", "-", "*", "/", "=", "!="}

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

      @nodes.select &.is_a?(Operator)
    end

    def parse_node(token : Token) : Node
      node : Node

      case token.kind
      in Kind::Number
        if token.value!.ends_with? '.'
          raise "Invalid number literal"
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
          raise "Invalid field name"
        end

        split = token.value!.split '.'
        raise "Invalid field name" if split.any? &.blank?

        node = Field.new token.start, token.stop, token.value!
      in Kind::Operator
        unless token.value!.in?(Parser::VALID_OPERATORS)
          raise "Invalid operator '#{token.value!}'"
        end

        if left = previous_node
          raise "Cannot use type #{left} for left-side expression" unless left.is_a?(Literal)
          right = parse_node @tokens[@pos + 1]
          raise "Cannot use type #{right} for right-side expression" unless right.is_a?(Literal)

          node = Operator.new token.start, token.stop, token.value!, left, right
        else
          raise "Missing left-side expression for operator"
        end
      in Kind::Eol
        raise "Unexpected End-Of-Line"
      end

      node
    end

    private def previous_node : Node?
      @nodes.last?
    end
  end
end