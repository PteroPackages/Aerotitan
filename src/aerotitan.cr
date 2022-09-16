require "cli"

require "./bindings"
require "./compile"
require "./syntax/*"

module Aerotitan
  VERSION = "0.1.0"

  def self.run : Nil
    app = CLI::Application.new
    app.help_template = Commands::RootCommand.help_template
    app.add_command Commands::RootCommand, default: true

    app.run ARGV
  end
end

Aerotitan.run
