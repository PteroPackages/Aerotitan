module Aero::Query
  class Parser
    enum Precedence
      Lowest
      Equals
      Sum
      # LessGreater
      # Product

      def self.from(kind : Token::Kind)
        case kind
        when .equal?, .not_equal? then Precedence::Equals
        when .and?, .or? then Precedence::Sum
        else Precedence::Lowest
        end
      end
    end

    @tokens : Array(Token)
    @pos : Int32

    def initialize(@tokens)
      @pos = 0
    end

    def parse : Array(Expression)
      expressions = [] of Expression

      loop do
        expr = parse_expression :lowest
        break if expr.nil?
        expressions << expr
      end

      expressions
    end

    private def parse_expression(prec : Precedence) : Expression?
      left = parse_expression current_token
      return nil if left.nil?

      loop do
        break if current_token.kind.eol?
        break if prec >= Precedence.from peek_token.kind

        case peek_token.kind
        when .equal?, .not_equal?
          left = parse_operator left
          break if current_token.kind.eol?
          next_token
        when .and?, .or?
          left = parse_statement left
          break if current_token.kind.eol?
          next_token
        else
          break
        end
      end

      left
    end

    private def parse_expression(token : Token) : Expression?
      case token.kind
      when .ident? then Identifier.new token
      when .number? then NumberLiteral.new token
      when .string? then StringLiteral.new token
      when .true?, .false? then BooleanLiteral.new token
      when .null? then NullLiteral.new token.start, token.stop
      end
    end

    private def parse_operator(left : Node) : Expression
      next_token
      kind = current_token.kind

      next_token
      prec = Precedence.from current_token.kind
      right = parse_expression prec
      raise "Missing right-side expression for operator" if right.nil?

      Operator.new kind, left, right
    end

    private def parse_statement(left : Node) : Expression
      next_token
      op = current_token.kind

      next_token
      prec = Precedence.from current_token.kind
      right = parse_expression prec
      raise "Missing right-side expression for statement" if right.nil?

      if op.and?
        And.new left, right
      else
        Or.new left, right
      end
    end

    private def current_token : Token
      @tokens[@pos]
    end

    private def peek_token : Token
      @tokens[@pos + 1]
    end

    private def next_token : Token
      @tokens[@pos += 1]
    end
  end
end
