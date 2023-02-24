require "cling"
require "colorize"
require "crest"
require "ecr/macros"
require "json"

require "./commands/*"
require "./actions"
require "./config"
require "./errors"
require "./log"
require "./models"
require "./template/*"

module Aerotitan
  VERSION = "0.1.0"

  class App < Commands::BaseCommand
    def setup : Nil
      @name = "aero"
      add_usage "aero <command> [arguments] [options]"
      add_option 'v', "version", description: "get the current version"

      add_command Commands::ConfigCommand.new
      add_command Commands::ExecCommand.new

      Config.load
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      if options.has? "version"
        stdout.puts "Aerotitan v#{VERSION}"
      else
        stdout.puts help_template
      end
    end
  end
end
