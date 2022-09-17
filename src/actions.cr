module Aerotitan::Actions
  # key => {can_use_query, requires_data}
  APP_ACTIONS = {
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
end
