module Aerotitan::Bind
  struct Binding
    @func : Entry -> Bool

    def initialize(@func)
    end
  end

  def self.bind_operator(op : Operator, entry : Entry)
  end
end
