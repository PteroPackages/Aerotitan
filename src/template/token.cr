module Aerotitan::Template
  enum Kind
    Number
    String
    Bool
    Null
    Space
    Ident
    Dot
    Comma
    LeftParen
    RightParen
    Eol
  end

  struct Token
    property start  : Int32
    property stop   : Int32
    property kind   : Kind
    property value  : String?

    def initialize(@start)
      @stop = 0
      @kind = :eol
    end
  end
end
