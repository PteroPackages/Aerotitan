module Aerotitan::Commands
  class InitCommand < CLI::Command
    def setup : Nil
      @name = "init"
      @usage << "init [-c|--clean] [-f|--force] [--url <url>] [--key <key>]"
      @description = "Initializes a new Aero config file"

      add_option "clean", short: "c"
      add_option "force", short: "f"
      add_option "url", kind: :string
      add_option "key", kind: :string
    end

    def execute(args, options) : Nil
      path = File.join Dir.current, ".aero.yml"
      if File.exists? path
        unless options.has? "force"
          Log.fatal ["A config file already exists in this directory:", path]
        end
      end

      cfg = if options.has?("clean")
        Config.new(options.get("url"), options.get("key")).to_yaml
      else
        Config.get_template options.get("url"), options.get("key")
      end

      begin
        File.write path, cfg
      rescue ex
        Log.fatal ex
      end
    end
  end
end
