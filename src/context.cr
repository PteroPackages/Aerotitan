module Aerotitan::Context
  struct Entry
    def initialize(&@func : JSON::Any -> Bool)
    end

    def execute(data : JSON::Any) : Bool
      @func.call data
    end
  end

  struct Result
  end
end
