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

    def initialize(kind : Template::OpKind, left : Template::Value, right : Template::Value)
      @start = left.start
      @stop = right.stop

      super "Cannot compare #{kind} with types #{left} and #{right}"
    end
  end
end
