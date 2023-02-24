module Aero::Commands
  class ExecCommand < BaseCommand
    def setup : Nil
      @name = "exec"
      add_usage "exec <action> [-i|--ignore <...>] [-p|--priority <...>] [-q|--query <str>]"

      add_argument "action", required: true
      add_option 'i', "ignore", type: :array, default: %w()
      add_option 'p', "priority", type: :array, default: %w()
      add_option 'q', "query", type: :single
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      action = arguments.get("action").as_s

      unless Actions::COMMANDS.includes? action
        Log.error "Invalid action '#{action}'"
        Log.info ["Valid Actions:"] + Actions::COMMANDS
        exit 1
      end

      ignore = options.get("ignore").as_a
      priority = options.get("priority").as_a
      query = options.get?("query").try &.as_s
      ignore.reject! &.in? priority

      case action
      when "servers:start", "servers:stop", "servers:restart", "servers:kill"
        handle_server_power ignore, priority, query
      end

      # TODO:
      # rescue SyntaxError
      # rescue ComparisonError
    end

    private def handle_server_power(ignore : Array(String), priority : Array(String), query : String?) : Nil
      servers = Actions.get_all_servers
      servers.reject! { |s| ignore.includes?(s["id"].as_i) || ignore.includes?(s["identifier"].as_s) }

      unless query.nil?
        results = Template.compile query, "server", Models::SERVER_FIELDS
        servers.select! { |s| results.any? &.execute(s) }
      end

      Log.fatal "No servers found matching the requirements" if servers.empty?
    end
  end
end
