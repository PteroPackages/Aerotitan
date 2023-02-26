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

    def put_info(data : String) : Nil
      stdout.puts data
    end

    def put_info(data : Array(String)) : Nil
      data.map { |d| stdout.puts d }
    end

    def put_warn(data : String) : Nil
      stdout.puts "#{"Warn ".colorize.yellow} #{data}"
    end

    def put_warn(data : Array(String)) : Nil
      data.map { |d| warn d }
    end

    def put_error(data : String) : Nil
      stderr.puts "#{"Error".colorize.red} #{data}"
    end

    def put_error(ex : Exception) : Nil
      error ex.message || ex.to_s
    end

    def put_error(data : Array(String | Exception)) : Nil
      data.map { |d| put_error d }
    end

    def format_template_error(ex : TemplateError, query : String) : Nil
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

      put_error %(#{message} (column #{ex.start}#{" to #{ex.stop}" unless ex.start == ex.stop}))
      put_error [
        "",
        "#{border} #{query}",
        %(#{border} #{padding}#{"^".colorize.yellow.to_s * width}),
        "#{border} #{ex}",
        "",
        "See 'aero help query' for more information",
      ]
    end
  end
end
