module Aerotitan::Commands
  abstract class BaseCommand < CLI::Command
    def initialize
      super

      @inherit_options = true
      add_option "no-color", description: "disable ansi color codes"
      add_option 'h', "help", description: "sends help information"
    end

    def pre_run(arguments, options)
      if options.has? "help"
        stdout.puts help_template

        false
      else
        true
      end
    end
  end
end
