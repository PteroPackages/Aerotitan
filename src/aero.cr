require "cling"
require "colorize"
require "crest"
require "ecr/macros"
require "json"

require "./commands/*"
require "./actions"
require "./config"
require "./errors"
require "./models"
require "./template/*"

Colorize.on_tty_only!

module Aero
  VERSION = "0.1.0"

  class CLI < Commands::BaseCommand
    def setup : Nil
      @name = "aero"
      add_usage "aero <command> [arguments] [options]"
      add_option 'v', "version", description: "get the current version"

      add_command Commands::ConfigCommand.new
      add_command Commands::ExecCommand.new
      add_command Commands::TestCommand.new

      Config.load
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      if options.has? "version"
        stdout.puts "Aero v#{VERSION}"
      else
        stdout.puts help_template
      end
    end
  end
end
