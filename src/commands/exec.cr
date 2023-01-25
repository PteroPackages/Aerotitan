module Aerotitan::Commands
  class ExecCommand < BaseCommand
    def setup : Nil
      @name = "exec"

      add_usage "exec <action> [-i|--ignore <...>] [-p|--priority <...>] [-q|--query <str>]"

      add_argument "action", required: true
      add_option 'i', "ignore", has_value: true, default: ""
      add_option 'p', "priority", has_value: true, default: ""
      add_option 'q', "query", has_value: true
    end

    def run(arguments, options) : Nil
      action = arguments.get!("action").as_s

      unless Actions::COMMANDS.includes? action
        Log.error "Invalid action '#{action}'"
        Log.info ["Valid Actions:"] + Actions::COMMANDS
        exit 1
      end

      ignore = options.get!("ignore").as_s.split ','
      priority  = options.get!("priority").as_s.split ','
      ignore.reject! &.in? priority

      actions = Actions.new Config.url, Config.key
      servers = actions
        .get_all_servers
        .reject { |s| ignore.includes?(s["id"].as_i) || ignore.includes?(s["identifier"].as_s) }

      if query = arguments.get("query").try &.as_s
        results = Template.compile query, "server", Models::SERVER_FIELDS
        servers.select! { |s| results.any? &.execute(s) }
      end

      Log.fatal "No servers found matching the requirements" if servers.empty?

      pp servers
    end
  end
end
