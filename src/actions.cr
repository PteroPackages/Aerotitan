module Aerotitan::Actions
  extend self

  COMMANDS = [
    "servers:start",
    "servers:restart",
    "servers:stop",
    "servers:kill",
    "servers:command",
    "servers:reinstall",
    "servers:suspend",
    "servers:unsuspend",
  ]

  @@client = Crest::Resource.new Config.url, headers: default_headers

  def default_headers : Hash(String, String)
    {
      "User-Agent"    => "Aero Client #{VERSION}",
      "Authorization" => "Bearer #{Config.key}",
      "Content-Type"  => "application/json",
      "Accept-Type"   => "application/json",
    }
  end

  private def get_all(route : String) : Array(JSON::Any)
    response = @@client.get route
    objects = JSON.parse response.body
    data = objects["data"].as_a.map &.["attributes"]
    total = objects["meta"]["pagination"]["total"].as_i

    if total > 1
      (2..total).each do |page|
        response = @@client.get(route + "?page=#{page}")
        objects = JSON.parse(response.body)["data"].as_a.map &.["attributes"]
        data += objects
      end
    end

    data
  end

  def get_all_servers : Array(JSON::Any)
    get_all "/api/application/servers"
  end
end
