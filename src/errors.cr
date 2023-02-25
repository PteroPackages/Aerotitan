module Aero
  class TemplateError < Exception
    getter start : Int32
    getter stop : Int32

    def initialize(@message : String, @start : Int32, @stop : Int32)
    end
  end

  class ComparisonError < TemplateError
    def initialize(kind : Template::OpKind, left : Template::Value, right : Template::Value)
      super "Cannot compare #{kind.name} (#{kind}) with types #{left} and #{right}", left.start, right.stop
    end
  end

  class FieldError < TemplateError
  end

  class SyntaxError < TemplateError
  end
end
