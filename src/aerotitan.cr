require "cli"
require "colorize"
require "ecr/macros"
require "json"
require "yaml"

require "./commands/*"
require "./syntax/*"
require "./actions"
require "./config"
require "./context"
require "./errors"
require "./log"
require "./models"

module Aerotitan
  VERSION = "0.1.0"

  def self.run : Nil
    app = CLI::Application.new
    app.help_template = Commands::RootCommand.help_template
    app.add_command Commands::RootCommand, default: true
    app.add_command Commands::InitCommand

    app.run ARGV
  end
end

Aerotitan.run
