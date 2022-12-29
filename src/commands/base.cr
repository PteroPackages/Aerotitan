module Aerotitan::Commands
  abstract class BaseCommand < CLI::Command
    def initialize
      super

      @inherit_options = true
      add_option "no-color", desc: "disable ansi color codes"
      add_option 'h', "help", desc: "sends help information"
    end

    def pre_run(args, options)
      if options.has? "help"
        stdout.puts help_template

        false
      else
        true
      end
    end
  end
end
