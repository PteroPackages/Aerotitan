module Aerotitan
  def self.compile_and_bind(input : String, data : JSON::Any) : Array(Entry)
    tokens = Synax::Lexer.new(input).run
    nodes = Syntax::Parser.new(tokens).run

    # only operators at the moment
    Bind.validate_nodes nodes, data
    entries = nodes.map { |n| Bind.bind_operator(n, data) }
    passed = entries.select &.execute
    passed
  end
end
