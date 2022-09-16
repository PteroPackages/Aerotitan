module Aerotitan::Commands
  class RootCommand < CLI::Command
    def self.help_template : String
      <<-HELP
      Aerotitan: Bulk Action Tool

      Usage:
          aero <command> [arguments] [options]

      Commands:
          init
          query
          exec
          run

      Global Options:
          -h, --help
          -v, --version
      HELP
    end

    def setup : Nil
      @name = "root"
      @help_template = self.class.help_template

      add_option "help", short: "h"
      add_option "version", short: "v"
    end

    def execute(args, options) : Nil
      if options.has? "version"
        puts "Aerotitan v#{Aerotitan::VERSION}"
      else
        puts help_template
      end
    end
  end
end
