module Aero::Commands
  abstract class BaseCommand < Cling::Command
    def initialize
      super

      @inherit_options = true
      add_option "no-color", description: "disable ansi color codes"
      add_option 'h', "help", description: "sends help information"
    end

    def pre_run(arguments : Cling::Arguments, options : Cling::Options) : Bool
      if options.has? "help"
        stdout.puts help_template

        false
      else
        true
      end
    end

    protected def info(data : _) : Nil
      stdout.puts data
    end

    protected def info(data : Array(_)) : Nil
      data.map { |d| stdout.puts d }
    end

    protected def warn(data : _) : Nil
      stdout.puts "#{"Warn ".colorize.yellow} #{data}"
    end

    protected def warn(data : Array(_)) : Nil
      data.map { |d| warn d }
    end

    protected def error(ex : Exception) : Nil
      error ex.message || ex.to_s
    end

    protected def error(data : _) : Nil
      stderr.puts "#{"Error".colorize.red} #{data}"
    end

    protected def error(data : Array(_)) : Nil
      data.map { |d| error d }
    end

    protected def format_template_error(ex : TemplateError, query : String) : Nil
      border = "|".colorize.red.to_s
      padding = " " * query[...ex.start].size
      width = ex.stop - ex.start + (ex.is_a?(SyntaxError) ? 1 : 0)
      message = case ex
                when ComparisonError
                  "Failed to evaluate query input"
                when FieldError
                  "Failed to interpret query input"
                when SyntaxError
                  "Failed to parse query input"
                end

      error %(#{message} (column #{ex.start}#{" to #{ex.stop}" unless ex.start == ex.stop}))
      error [
        "",
        "#{border} #{query}",
        %(#{border} #{padding}#{"^".colorize.yellow.to_s * width}),
        "#{border} #{ex}",
        "",
        "See 'aero help query' for more information",
      ]
    end

    protected def system_exit : NoReturn
      raise SystemExit.new
    end
  end
end
