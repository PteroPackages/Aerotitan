module Aerotitan
  class Action
    include YAML::Serializable

    KEYS = {
      # key => {can_use_query, requires_data}
      "users:select" => {true, false},
      # "users:create" => {false, true},
      # "users:update" => {true, true},
      "users:delete" => {true, false},
      "servers:select" => {true, false},
      # "servers:create" => {true, true},
      # "servers:update" => {true, true},
      "servers:delete" => {true, false},
      "servers:suspend" => {true, false},
      "servers:unsuspend" => {true, false},
      "servers:reinstall" => {true, false}
    }

    @name : String
    @priority : Array(String) = [] of String
    @query : Array(String) = [] of String
    @ignore : Array(String) = [] of String

    def name
      @name
    end

    def priority
      @priority
    end

    def number_priority
      @priority.map(&.to_i?).uniq
    end

    def query
      @query
    end

    def ignore
      @ignore
    end

    def number_ignore
      @ignore.map(&.to_i?).uniq
    end
  end
end
