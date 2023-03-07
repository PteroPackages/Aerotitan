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
        error "Invalid action '#{action}'"
        info ["Valid Actions:"] + Actions::COMMANDS
        system_exit
      end

      ignore = options.get("ignore").as_a
      priority = options.get("priority").as_a
      query = options.get?("query").try &.as_s
      ignore.reject! &.in? priority

      case action
      when "servers:start", "servers:stop", "servers:restart", "servers:kill"
        handle_server_power ignore, priority, query, action[8...]
      when "servers:suspend"
        handle_server_suspend ignore, priority, query
      end
    rescue ex : TemplateError
      format_template_error ex, query.not_nil!
    end

    private def handle_server_power(ignore : Array(String), priority : Array(String),
                                    query : String?, action : String) : Nil
      result = Template.compile query, "server", Models::SERVER_FIELDS
      servers = Actions.get_all_servers
      servers.reject! { |s| ignore.includes?(s["id"].as_i) || ignore.includes?(s["identifier"].as_s) }
      servers.select! { |s| result.execute(s) } if result.value?

      if servers.empty?
        error "No servers found matching the requirements"
        system_exit
      end

      servers.each do |server|
        info "Sending action #{action} to #{server["identifier"]}"
        Actions.send_server_power server["identifier"].as_s, action
      rescue Crest::Conflict
        warn "failed to #{action} server #{server["identifier"]}: conflict"
      end
    end

    private def handle_server_suspend(ignore : Array(String), priority : Array(String),
                                      query : String?) : Nil
      result = Template.compile query, "server", Models::SERVER_FIELDS
      servers = Actions.get_all_servers
      servers.reject! { |s| ignore.includes?(s["id"].as_i) || ignore.includes?(s["identifier"].as_s) }
      servers.reject! &.["status"].as_s? == "suspended"
      servers.select! { |s| result.execute(s) } if result.value?

      if servers.empty?
        error "No servers found matching the requirements"
        system_exit
      end

      servers.each do |server|
        info "Suspending server #{server["identifier"]}"
        Actions.suspend_server server["id"].as_i
      end
    end

    private def handle_server_unsuspend(ignore : Array(String), priority : Array(String),
                                        query : String?) : Nil
      result = Template.compile query, "server", Models::SERVER_FIELDS
      servers = Actions.get_all_servers
      servers.reject! { |s| ignore.includes?(s["id"].as_i) || ignore.includes?(s["identifier"].as_s) }
      servers.select! { |s| result.execute(s) } if result.value?

      if servers.empty?
        error "No servers found matching the requirements"
        system_exit
      end

      servers.each do |server|
        info "Unsuspending server #{server["identifier"]}"
        Actions.unsuspend_server server["id"].as_i
      end
    end
  end
end
