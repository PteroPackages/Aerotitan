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

    def run(arguments, options) : Nil
      url = Config.url.empty? ? "not set" : Config.url
      key = Config.key.empty? ? "not set" : Config.key
      Log.info ["url: #{url}", "key: #{key}"]
    end
  end

  class SetURLCommand < BaseCommand
    def setup : Nil
      @name = "set-url"
      @summary = "sets the panel url in the config"

      add_argument "url", description: "the panel url", required: true
    end

    def run(arguments, options) : Nil
      Config.write arguments.get!("url").as_s, nil
    end
  end

  class SetKeyCommand < BaseCommand
    def setup : Nil
      @name = "set-key"
      @summary = "sets the panel api key in the config"

      add_argument "key", description: "the panel api key", required: true
    end

    def run(arguments, options) : Nil
      Config.write nil, arguments.get!("key").as_s
    end
  end
end
