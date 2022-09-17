module Aerotitan::Context
  struct Entry
    def initialize(&@func : JSON::Any -> Bool)
    end
  end

  struct Result
  end
end
