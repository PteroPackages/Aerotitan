module Aero::Actions
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

  private class_getter client : Crest::Resource do
    Crest::Resource.new Config.url, headers: default_headers
  end

  def default_headers : Hash(String, String)
    {
      "User-Agent"    => "Aero Client #{VERSION}",
      "Authorization" => "Bearer #{Config.key}",
      "Content-Type"  => "application/json",
      "Accept-Type"   => "application/json",
    }
  end

  private def get_all(route : String) : Array(JSON::Any)
    response = client.get route
    objects = JSON.parse response.body
    data = objects["data"].as_a.map &.["attributes"]
    total = objects["meta"]["pagination"]["total"].as_i

    if total > 1
      (2..total).each do |page|
        response = client.get(route + "?page=#{page}")
        objects = JSON.parse(response.body)["data"].as_a.map &.["attributes"]
        data += objects
      end
    end

    data
  end

  def get_all_servers : Array(JSON::Any)
    get_all "/api/application/servers"
  end

  def send_server_power(id : String, signal : String) : Nil
    client.post "/api/client/servers/#{id}/power", {"signal" => signal}
  end
end
