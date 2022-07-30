require "./token"

module Aerotitan::Template
  abstract struct Node
    property start  : Int32
    property stop   : Int32

    def initialize(@start, @stop); end

    def accepts?(other : Node) : Bool
      false
    end
  end

  struct NumberLiteral < Node
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

  struct StringLiteral < Node
    property value : String

    def initialize(@start, @stop, @value); end

    def accepts?(other : Node) : Bool
      other.is_a? self.class || other.is_a? String
    end

    def to_s(io : IO) : Nil
      io << "string"
    end
  end

  struct BoolLiteral < Node
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

  struct NullLiteral < Node
    def accepts?(other : Node) : Bool
      other.is_a? self.class || other.nil?
    end

    def to_s(io : IO) : Nil
      io << "null"
    end
  end

  struct FieldNode < Node
    property name     : String
    property parents  : Array(String)

    def initialize(@start, @stop, names)
      @name = names.last
      @parents = names[..names.size-2]
    end
  end

  struct FuncNode < Node
    property name : String
    property args : Array(Node)

    def initialize(@start, @stop, @name, @args); end
  end
end
