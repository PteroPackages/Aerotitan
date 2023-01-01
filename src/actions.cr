module Aerotitan::Actions
  extend self

  COMMANDS = [
    "servers:power",
    "servers:command",
    "servers:reinstall",
    "servers:suspend",
    "servers:unsuspend",
  ]

  # TODO
  def get_all_servers
    []
  end

  def send_server_power(target : Array(String), ignore : Array(String))
  end
end
