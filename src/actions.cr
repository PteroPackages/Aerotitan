module Aerotitan
  class Action
    KEYS = {
      # key => {can_use_query, requires_data}
      # "users:create" => {false, true},
      # "users:update" => {true, true},
      "users:delete" => {true, false},
      # "servers:create" => {true, true},
      # "servers:update" => {true, true},
      "servers:delete"    => {true, false},
      "servers:suspend"   => {true, false},
      "servers:unsuspend" => {true, false},
      "servers:reinstall" => {true, false},
    }

    getter name : String
    getter priority : Array(String)
    getter query : Array(String)
    getter ignore : Array(String)

    def initialize(@name, priority : Array(String)? = nil, query : Array(String)? = nil, ignore : Array(String)? = nil)
      raise "Invalid action '#{name}'" unless KEYS.has_key? @name

      @priority = priority || [] of String
      @query = query || [] of String
      @ignore = ignore || [] of String
    end

    def get_handler : Handler
    end
  end
end
