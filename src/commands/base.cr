module Aerotitan::Commands
  abstract class BaseCommand < CLI::Command
    @inherit_options = true

    def initialize
      super

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
