require "cli"
require "colorize"
require "ecr/macros"
require "json"
require "yaml"

require "./commands/*"
require "./actions"
require "./config"
require "./context"
require "./errors"
require "./log"
require "./models"
require "./syntax/*"

module Aerotitan
  VERSION = "0.1.0"

  class App < Commands::BaseCommand
    def initialize
      super

      add_usage "aero <command> [arguments] [options]"

      add_command Commands::InitCommand.new

      add_option 'v', "version", desc: "get the current version"
    end

    def setup : Nil
      @name = "aero"
    end

    def run(args, options) : Nil
      if options.has? "version"
        stdout.puts "Aerotitan v#{VERSION}"
      else
        stdout.puts help_template
      end
    end
  end
end
