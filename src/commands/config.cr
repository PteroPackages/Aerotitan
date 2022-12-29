module Aerotitan::Commands
  class ConfigCommand < BaseCommand
    def setup : Nil
      @name = "config"
      @summary = "config management commands"

      add_usage "config init [<url> <key>]"
      add_usage "config set-url <url>"
      add_usage "config set-key <key>"

      add_command SetURLCommand.new
      add_command SetKeyCommand.new
    end

    def run(args, options) : Nil
      url = Config.url.empty? ? "not set" : Config.url
      key = Config.key.empty? ? "not set" : Config.key
      Log.info ["url: #{url}", "key: #{key}"]
    end
  end

  class SetURLCommand < BaseCommand
    def setup : Nil
      @name = "set-url"
      @summary = "sets the panel url in the config"

      add_argument "url", desc: "the panel url", required: true
    end

    def run(args, options) : Nil
      Config.write args.get!("url").as_s, nil
    end
  end

  class SetKeyCommand < BaseCommand
    def setup : Nil
      @name = "set-key"
      @summary = "sets the panel api key in the config"

      add_argument "key", desc: "the panel api key", required: true
    end

    def run(args, options) : Nil
      Config.write nil, args.get!("key").as_s
    end
  end
end
