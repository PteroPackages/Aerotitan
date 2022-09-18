module Aerotitan
  class SyntaxError < Exception
    getter start : Int32
    getter stop : Int32

    def initialize(message : String, @start : Int32, @stop : Int32)
      super message + " (#{@start}:#{@stop})"
    end
  end

  class ComparisonError < Exception
    getter start : Int32
    getter stop : Int32

    def initialize(kind : Syntax::OpKind, left : Syntax::ValueRef, right : Syntax::ValueRef)
      @start = left.start
      @stop = right.stop

      super "Cannot compare #{kind} with types #{left} and #{right}"
    end
  end
end
