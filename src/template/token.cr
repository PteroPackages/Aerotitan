enum Kind
  Number
  String
  Bool
  Null
  Space
  Field
  Access
  OpEq
  Eof
end

struct Token
  property start  : Int32
  property end    : Int32
  property kind   : Kind
  @value          : String?

  def initialize(@start)
    @end = 0
    @kind = :eof
  end

  def value : String?
    @value
  end

  def value=(v : String)
    @value = v
  end

  def value=(v : Array(Char))
    @value = v.join
  end
end
