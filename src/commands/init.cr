module Aerotitan::Commands
  class InitCommand < BaseCommand
    def setup : Nil
      @name = "init"
      @summary = @description = "Initializes a new Aero config file"
      add_usage "init [-c|--clean] [-f|--force] [--url <url>] [--key <key>]"

      add_option 'c', "clean"
      add_option 'f', "force"
      add_option "url", has_value: true
      add_option "key", has_value: true
    end

    def run(args, options) : Nil
      path = File.join Dir.current, ".aero.yml"
      if File.exists? path
        unless options.has? "force"
          Log.fatal ["A config file already exists in this directory:", path]
        end
      end

      url = options.get("url").try &.as_s
      key = options.get("key").try &.as_s
      cfg = if options.has? "clean"
        Config.new(url, key).to_yaml
      else
        Config.get_template url, key
      end

      begin
        File.write path, cfg
      rescue ex
        Log.fatal ex
      end
    end
  end
end
