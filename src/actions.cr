module Aerotitan
  class Actions
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

    def initialize(@url : String, @key : String)
      @client = Crest::Resource.new @url, headers: headers
    end

    def headers : Hash(String, String)
      {
        "User-Agent"    => "Aerotitan Client #{VERSION}",
        "Authorization" => "Bearer #{@key}",
        "Content-Type"  => "application/json",
        "Accept-Type"   => "application/json",
      }
    end

    def get_all_servers : Array(JSON::Any)
      res = @client.get "/api/application/servers"
      obj = JSON.parse res.body
      data = obj["data"].as_a.map &.["attributes"]
      total = obj["meta"]["pagination"]["total"].as_i

      if total > 1
        (2..total).each do |i|
          res = @client.get "/api/application/servers?page=#{i}", headers: headers
          obj = JSON.parse(res.body)["data"].as_a.map &.["attributes"]
          data += obj
        end
      end

      data
    end

    def send_server_power(target : Array(String), ignore : Array(String))
    end
  end
end
