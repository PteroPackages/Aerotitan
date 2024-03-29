module Aero::Template
  enum OpKind
    Eq
    Neq
    Lt
    Lte
    Gt
    Gte

    def self.from(value : String)
      case value
      when "==" then OpKind::Eq
      when "!=" then OpKind::Neq
      when "<"  then OpKind::Lt
      when "<=" then OpKind::Lte
      when ">"  then OpKind::Gt
      when ">=" then OpKind::Gte
      else
        raise "invalid operator"
      end
    end

    def to_s : String
      case self
      in OpKind::Eq  then "=="
      in OpKind::Neq then "!="
      in OpKind::Lt  then "<"
      in OpKind::Lte then "<="
      in OpKind::Gt  then ">"
      in OpKind::Gte then ">="
      end
    end

    def name : String
      case self
      in OpKind::Eq  then "equal"
      in OpKind::Neq then "not equal"
      in OpKind::Lt  then "less than"
      in OpKind::Lte then "less than or equal"
      in OpKind::Gt  then "greater than"
      in OpKind::Gte then "greater than or equal"
      end
    end
  end

  class Parser
    VALID_OPERATORS = {"==", "!=", "<", "<=", ">", ">="}
    OTHER_OPERATORS = {"+", "++", "-", "--", "*", "**", "/", "//", "^", "%"}

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
      in Token::Kind::Number
        if token.value!.ends_with? '.'
          raise SyntaxError.new("Invalid number literal", token.start, token.stop)
        end

        node = NumberLiteral.new token.start, token.stop, token.value!
      in Token::Kind::String
        node = StringLiteral.new token.start, token.stop, token.value!
      in Token::Kind::Bool
        node = BoolLiteral.new token.start, token.stop, token.value!
      in Token::Kind::Null
        node = NullLiteral.new token.start, token.stop
      in Token::Kind::Space
        return parse_node @tokens[@pos += 1]
      in Token::Kind::Ident
        if token.value!.ends_with?('.') || token.value!.ends_with?('_')
          raise FieldError.new("Invalid field name", token.start, token.stop)
        end

        split = token.value!.split '.'
        raise FieldError.new("Invalid field name", token.start, token.stop) if split.any? &.blank?

        node = Field.new token.start, token.stop, token.value!
      in Token::Kind::Operator
        unless token.value!.in? VALID_OPERATORS
          if token.value!.in? OTHER_OPERATORS
            raise SyntaxError.new("Cannot do arithmetic operations yet", token.start, token.stop)
          end

          raise SyntaxError.new("Invalid operator '#{token.value!}'", token.start, token.stop)
        end

        if left = previous_node
          unless left.is_a? Literal
            raise SyntaxError.new("Cannot use type #{left} for left-side expression", token.start, token.stop)
          end

          right = parse_node @tokens[@pos + 1]
          unless right.is_a? Literal
            raise SyntaxError.new("Cannot use type #{right} for right-side expression", token.start, token.stop)
          end

          node = Operator.new token.start, token.stop, OpKind.from(token.value!), left, right
        else
          raise SyntaxError.new("Missing left-side expression for operator", token.start, token.stop)
        end
      in Token::Kind::Eol
        raise SyntaxError.new("Unexpected End-Of-Line", token.start, token.stop)
      end

      node
    end

    private def previous_node : Node?
      @nodes.last?
    end
  end
end
