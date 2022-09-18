module Aerotitan::Syntax
  private module Default
    abstract def default
  end

  abstract struct Node
    macro inherited
      extend Default
    end

    property start  : Int32
    property stop   : Int32

    def initialize(@start, @stop)
    end

    def accepts?(other : Node) : Bool
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

    def self.default
      new 0, 0, 0
    end

    def accepts?(other : Node) : Bool
      other.is_a?(NumberLiteral)
    end

    def to_s(io : IO) : Nil
      io << "number"
    end
  end

  struct StringLiteral < Literal
    property value : String

    def initialize(@start, @stop, @value)
    end

    def self.default
      new 0, 0, ""
    end

    def accepts?(other : Node) : Bool
      other.is_a?(StringLiteral) || other.is_a?(NullableString)
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

    def self.default
      new 0, 0, false
    end

    def accepts?(other : Node) : Bool
      other.is_a?(BoolLiteral)
    end

    def to_s(io : IO) : Nil
      io << "boolean"
    end
  end

  struct NullLiteral < Literal
    def self.default
      new 0, 0
    end

    def value : Nil
      nil
    end

    def accepts?(other : Node) : Bool
      other.is_a?(NullLiteral) || other.is_a?(Nullable)
    end

    def to_s(io : IO) : Nil
      io << "null"
    end
  end

  abstract struct Nullable < Node
  end

  struct NullableString < Nullable
    def self.default
      new 0, 0
    end

    def self.accepts?(other : Node) : Bool
      other.is_a?(NullableString) || other.is_a?(StringLiteral)
    end
  end

  alias ValueRef = Literal | Nullable

  struct Field < Literal
    property value : String

    def initialize(@start, @stop, @value)
    end

    def self.default
      new 0, 0, ""
    end

    def to_s(io : IO)
      io << @value
    end
  end

  struct Operator < Node
    property kind : OpKind
    property left : Literal
    property right : Literal

    def initialize(@start, @stop, @kind, @left, @right)
    end

    def self.default
      new 0, 0, :eq, NullLiteral.default, NullLiteral.default
    end

    def to_s(io : IO)
      io << @kind
    end
  end
end
