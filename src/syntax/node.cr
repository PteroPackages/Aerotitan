module Aerotitan::Syntax
  abstract struct Node
    property start  : Int32
    property stop   : Int32

    def initialize(@start, @stop)
    end

    def accepts?(other : Node) : Bool
      false
    end

    def accepts?(other : Node.class) : Bool
      false
    end
  end

  abstract struct Literal < Node
  end

  struct NumberLiteral < Literal
    property value : Float64

    def initialize(@start, @stop, value)
      @value = value.to_f
    end

    def accepts?(other : Literal.class) : Bool
      other == NumberLiteral
    end

    def to_s(io : IO) : Nil
      io << "number"
    end
  end

  struct StringLiteral < Literal
    property value : String

    def initialize(@start, @stop, @value)
    end

    def accepts?(other : Node) : Bool
      other.is_a?(StringLiteral) || other.is_a?(NullableString)
    end

    def accepts?(other : Node.class) : Bool
      other == StringLiteral || other == NullableString
    end

    def to_s(io : IO) : Nil
      io << "string"
    end
  end

  struct BoolLiteral < Literal
    property value : Bool

    def initialize(@start, @stop, value)
      case value
      when "true"   then @value = true
      when "false"  then @value = false
      else
        raise "invalid boolean literal"
      end
    end

    def accepts?(other : Node) : Bool
      other.is_a?(BoolLiteral)
    end

    def accepts?(other : Node.class) : Bool
      other == BoolLiteral
    end

    def to_s(io : IO) : Nil
      io << "boolean"
    end
  end

  struct NullLiteral < Literal
    def value : Nil
      nil
    end

    def accepts?(other : Node) : Bool
      other.is_a?(NullLiteral) || other.is_a?(Nullable)
    end

    def accepts?(other : Node.class) : Bool
      other < Nullable
    end

    def to_s(io : IO) : Nil
      io << "null"
    end
  end

  abstract struct Nullable < Node
  end

  struct NullableString < Nullable
    def self.accepts?(other : Node) : Bool
      other.is_a?(NullableString) || other.is_a?(StringLiteral)
    end

    def self.accepts(other : Node.class) : Bool
      other == NullableString || other == StringLiteral
    end
  end

  alias ValueRef = Literal | Nullable

  struct Field < Literal
    property value : String

    def initialize(@start, @stop, @value)
    end

    def to_s(io : IO)
      io << @value
    end
  end

  struct Operator < Node
    property kind : Operators
    property left : Literal
    property right : Literal

    def initialize(@start, @stop, @kind, @left, @right)
    end

    def to_s(io : IO)
      io << @kind
    end
  end
end
