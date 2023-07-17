module Aero::Query
  abstract class Node
    getter start : Int32
    getter stop : Int32

    def initialize(@start, @stop)
    end
  end

  abstract class Expression < Node
  end

  class Identifier < Expression
    getter value : String

    def initialize(token : Token)
      super token.start, token.stop
      @value = token.value
    end
  end

  class NumberLiteral < Expression
    getter value : Float64

    def initialize(token : Token)
      super token.start, token.stop
      @value = token.value.to_f
    end
  end

  class StringLiteral < Expression
    getter value : String

    def initialize(token : Token)
      super token.start, token.stop
      @value = token.value
    end
  end

  class BooleanLiteral < Expression
    getter value : Bool

    def initialize(token : Token)
      super token.start, token.stop
      @value = token.kind.true?
    end
  end

  class NullLiteral < Expression
  end

  class Operator < Expression
    enum Kind
      Equal
      NotEqual
      Add
    end

    getter left : Expression
    getter op : Kind
    getter right : Expression

    def initialize(kind : Token::Kind, @left, @right)
      super left.start, right.stop

      @op = case kind
      when .equal? then Kind::Equal
      when .not_equal? then Kind::NotEqual
      when .plus? then Kind::Add
      else raise "unreachable"
      end
    end
  end

  class And < Expression
    getter left : Expression
    getter right : Expression

    def initialize(@left, @right)
      super left.start, right.stop
    end
  end

  class Or < Expression
    getter left : Expression
    getter right : Expression

    def initialize(@left, @right)
      super left.start, right.stop
    end
  end
end
