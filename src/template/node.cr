require "./token"

abstract struct Node
  property start  : Int32
  property end    : Int32

  def initialize(token : Token)
    @start = token.start
    @end = token.end
  end

  def accepts?(other : Node) : Bool
    false
  end
end

struct Nop < Node
  def initialize(token)
    super token
  end
end

struct FieldNode < Node
  property name : String

  def initialize(token)
    super token
    @name = token.value.not_nil!
  end
end

struct AccessNode < Node
  def initialize(token)
    super token
  end
end

struct NumberLiteral < Node
  property value : Float64

  def initialize(token)
    super token
    @value = token.value.not_nil!.to_f
  end

  def accepts?(other : Node) : Bool
    other.is_a? self.class
  end

  def to_s : String
    "number"
  end
end

struct StringLiteral < Node
  property value : String

  def initialize(token)
    super token
    @value = token.value.not_nil!
  end

  def accepts?(other : Node) : Bool
    other.is_a? self.class || other.is_a? String
  end

  def to_s : String
    "string"
  end
end

struct BoolLiteral < Node
  property value : Bool

  def initialize(token)
    super token

    case token.value
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
  def initialize(token)
    super token
  end

  def accepts?(other : Node) : Bool
    other.is_a? self.class || other.nil?
  end

  def to_s : String
    "null"
  end
end

struct EqualsOp < Node
  def initialize(token)
    super token
  end
end
