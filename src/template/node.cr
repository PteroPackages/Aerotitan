module Aerotitan::Template
  private module Default
    abstract def default
  end

  abstract struct Node
    macro inherited
      extend Default
    end

    getter start : Int32
    getter stop : Int32

    def initialize(@start, @stop)
    end

    def accepts?(other : Node) : Bool
      false
    end
  end

  abstract struct Literal < Node
  end

  struct NumberLiteral < Literal
    getter value : Float64

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
    getter value : String

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
    getter value : Bool

    def initialize(@start, @stop, value)
      case value
      when "true"  then @value = true
      when "false" then @value = false
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

    def accepts?(other : Node) : Bool
      other.is_a?(NullableString) || other.is_a?(StringLiteral) || other.is_a?(NullLiteral)
    end

    def to_s(io : IO) : Nil
      io << "nullable string"
    end
  end

  alias Value = Literal | Nullable

  struct Field < Literal
    getter value : String

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
    getter kind : OpKind
    getter left : Literal
    getter right : Literal

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
