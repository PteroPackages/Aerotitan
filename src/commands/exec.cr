module Aerotitan::Commands
  class ExecCommand < BaseCommand
    def setup : Nil
      @name = "exec"

      add_usage "exec <action> [-i|--ignore <...>] [-p|--priority <...>] [-q|--query <str>]"

      add_argument "action", required: true
      add_option 'i', "ignore", has_value: true, default: ""
      add_option 'p', "priority", has_Value: true, default: ""
      add_option 'q', "query", has_value: true
    end

    def run(args, options) : Nil
      action = args.get!("action").as_s

      unless Actions::COMMANDS.includes? action
        Log.error "Invalid action '#{action}'"
        Log.info ["Valid Actions:"] + Actions::COMMANDS
        exit 1
      end

      ignore = args.get!("ignore").as_s.split ','
      priority  = args.get!("priority").as_s.split ','
      ignore.reject! &.in? priority

      servers = Actions
        .get_all_servers
        .reject { |s| ignore.includes?(s["id"]) || ignore.includes?(s["identifier"]) }

      if query = args.get("query")
        results = Template.compile query.as_s
        servers.select! { |s| results.any? &.execute(s) }
      end

      Log.fatal "No servers found matching the requirements" if servers.empty?
    end
  end
end
