module Aero::Commands
  class TestCommand < BaseCommand
    def setup : Nil
      @name = "test"
      add_usage "test <query> [-t|--target <name>]"

      add_argument "query", description: "the query input to test", required: true
      add_option 't', "target", description: "the target for the query"
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      input = arguments.get("query").as_s
      target = case
               when value = options.get?("scope")
                 value.as_s
               when input.includes?("user")
                 "user"
               when input.includes?("server")
                 "server"
               else
                 error [
                   "Cannot identify query target",
                   "Consider using the '--target' flag with this command",
                 ]
                 system_exit
               end

      fields = case target
               when "user"   then Models::USER_FIELDS
               when "server" then Models::SERVER_FIELDS
               else
                 error "Unknown query target '#{target}'"
                 system_exit
               end

      if input.blank?
        error "No query input given"
        system_exit
      end

      info "Testing #{target} query..."
      _ = Template.compile input, target, fields
      info "Query compiled with no errors"
    rescue ex : TemplateError
      format_template_error ex, input.not_nil!
    end
  end
end
