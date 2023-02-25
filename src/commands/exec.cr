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
        put_error "Invalid action '#{action}'"
        put_info ["Valid Actions:"] + Actions::COMMANDS
        exit 1
      end

      ignore = options.get("ignore").as_a
      priority = options.get("priority").as_a
      query = options.get?("query").try &.as_s
      ignore.reject! &.in? priority

      case action
      when "servers:start", "servers:stop", "servers:restart", "servers:kill"
        handle_server_power ignore, priority, query, action[8...]
      end
    rescue ex : ComparisonError
      format_error ex, query.not_nil!
    rescue ex : SyntaxError
      format_error ex, query.not_nil!
    end

    private def format_error(ex : ComparisonError | SyntaxError, query : String) : Nil
      border = "|".colorize.red.to_s
      padding = " " * query[...ex.start].size
      width = ex.stop - ex.start + (ex.is_a?(SyntaxError) ? 1 : 0)
      message = "Failed to #{ex.is_a?(ComparisonError) ? "evaluate" : "parse"} query syntax"

      put_error %(#{message} (column #{ex.start}#{" to #{ex.stop}" unless ex.start == ex.stop}))
      put_error [
        "",
        "#{border} #{query}",
        %(#{border} #{padding}#{"^".colorize.yellow.to_s * width}),
        "#{border} #{ex}",
        "",
        "See 'aero help query' for more information",
      ]
    end

    private def handle_server_power(ignore : Array(String), priority : Array(String),
                                    query : String?, action : String) : Nil
      servers = Actions.get_all_servers
      servers.reject! { |s| ignore.includes?(s["id"].as_i) || ignore.includes?(s["identifier"].as_s) }

      unless query.nil?
        result = Template.compile query, "server", Models::SERVER_FIELDS
        servers.select! { |s| result.execute(s) }
      end

      put_error "No servers found matching the requirements" if servers.empty?

      servers.each do |server|
        put_info "Sending action #{action} to #{server["identifier"]}"
        Actions.send_server_power server["identifer"].as_s, action
      end
    end
  end
end
