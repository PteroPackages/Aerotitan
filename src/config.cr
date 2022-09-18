module Aerotitan
  class Config
    include YAML::Serializable

    property panel_url : String
    property panel_key : String
    property actions : Array(Action)

    def initialize(panel_url : String?, panel_key : String?)
      @panel_url = panel_url || "https://pterodactyl.test"
      @panel_key = panel_key || "ptlc_cli3ntAp1Key"
      @actions = [] of Action
    end

    def self.get_template(panel_url : String?, panel_key : String?) : String
      panel_url ||= "https://pterodactyl.test"
      panel_key ||= "ptlc_cli3ntAp1Key"

      ECR.render "src/config.ecr"
    end
  end
end
