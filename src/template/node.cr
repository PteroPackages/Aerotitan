require "./token"

abstract struct Node
  property start  : Int32
  property end    : Int32

  def initialize(@start, @end); end

  def accepts?(other : Node) : Bool
    false
  end
end

struct Nop < Node; end

struct FieldNode < Node
  property name : String

  def initialize(@start, @end, @name); end
end

struct AccessNode < Node; end

struct NumberLiteral < Node
  property value : Float64

  def initialize(@start, @end, @value); end

  def accepts?(other : Node) : Bool
    other.is_a? self.class || other.is_a? Number
  end

  def to_s : String
    "number"
  end
end

struct StringLiteral < Node
  property value : String

  def initialize(@start, @end, @value); end

  def accepts?(other : Node) : Bool
    other.is_a? self.class || other.is_a? String
  end

  def to_s : String
    "string"
  end
end

struct BoolLiteral < Node
  property value : Bool

  def initialize(@start, @end, value)
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

  def to_s : String
    "boolean"
  end
end

struct NullLiteral < Node
  def accepts?(other : Node) : Bool
    other.is_a? self.class || other.nil?
  end

  def to_s : String
    "null"
  end
end

struct EqualsOp < Node; end
