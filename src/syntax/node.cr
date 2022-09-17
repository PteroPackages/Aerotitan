module Aerotitan::Syntax
  abstract struct Node
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

    def accepts?(other : Node) : Bool
      other.is_a? self.class || other.is_a? Number
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
      other.is_a? self.class || other.is_a? String
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
      other.is_a? self.class || other.is_a? Bool
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
      other.is_a? self.class || other.nil?
    end

    def to_s(io : IO) : Nil
      io << "null"
    end
  end

  struct NullableString < Literal
  end

  struct Field < Literal
    property value : String

    def initialize(@start, @stop, @value)
    end

    def to_s(io : IO)
      io << @value
    end
  end

  struct Operator < Node
    property symbol : String
    property left : Literal
    property right : Literal

    def initialize(@start, @stop, @symbol, @left, @right)
    end

    def to_s(io : IO)
      io << @symbol
    end
  end
end
