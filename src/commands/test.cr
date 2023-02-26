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
                 "users"
               when input.includes?("server")
                 "servers"
               else
                 put_error ["Cannot identify query target", "Consider using the '--target' flag with this command"]
                 return
               end

      fields = case target
               when "users"   then Models::USER_FIELDS
               when "servers" then Models::SERVER_FIELDS
               else
                 put_error "Unknown query target '#{target}'"
                 return
               end

      if input.blank?
        put_error "No query input given"
        return
      end

      # TODO: abstract this
      _ = Template.compile input, target, fields
      put_info "Query compiled with no errors"
    rescue ex : TemplateError
      format_template_error ex, input.not_nil!
    end
  end
end
