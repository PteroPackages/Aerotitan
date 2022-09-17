module Aerotitan
  class SyntaxError < Exception
    getter start : Int32
    getter stop : Int32

    def initialize(message : String, @start : Int32, @stop : Int32)
      super message + " (#{@start}:#{@stop})"
    end
  end
end
