module Aerotitan::Syntax
  def self.compile(input : String,
                   key : String,
                   fields : Array(String)) : Array(Context::Entry)
    tokens = Lexer.new(input).run
    nodes = Parser.new(tokens).run.select(Operator)

    validate_nodes(nodes, key, fields)
    nodes.map { |n| create_entry(n) }
  end

  private def self.validate_nodes(nodes : Array(Operator),
                                  key : String,
                                  fields : Array(String)) : Nil
    nodes.each do |node|
      if node.left.is_a?(Field)
        names = node.left.value.as(String).split '.'

        unless names[0] == key
          raise SyntaxError.new("Unknown object '#{names[0]}'", node.start, node.stop)
        end

        unless fields.includes?(names[1..])
          raise SyntaxError.new("Unknown field '#{names[1..]}' for object #{key}", node.start, node.stop)
        end
      end

      if node.right.is_a?(Field)
        names = node.right.value.as(String).split '.'

        unless names[0] == key
          raise SyntaxError.new("Unknown object '#{names[0]}'", node.start, node.stop)
        end

        unless fields.includes?(node.right.value)
          raise SyntaxError.new("Unknown field '#{names[1..]}' for object #{key}", node.start, node.stop)
        end
      end
    end
  end

  private def self.create_entry(op : Operator) : Context::Entry
    left = op.left.value
    right = op.right.value

    case op.symbol
    when "=="
      Context::Entry.new do |data|
        expand_node(left) == expand_node(right)
      end
    when "!="
      Context::Entry.new do |data|
        expand_node(left) != expand_node(right)
      end
    when "<"
      Context::Entry.new do |data|
        expand_node(left.as(Float64)) < expand_node(right.as(Float64))
      end
    when "<="
      Context::Entry.new do |data|
        expand_node(left.as(Float64)) <= expand_node(right.as(Float64))
      end
    when ">"
      Context::Entry.new do |data|
        expand_node(left.as(Float64)) > expand_node(right.as(Float64))
      end
    else # when ">="
      Context::Entry.new do |data|
        expand_node(left.as(Float64)) >= expand_node(right.as(Float64))
      end
    end
  end

  private macro expand_node(node)
    {% if node.is_a?(Field) %}
      {% names = node.value.split('.') %}
      {{ names[0].id }}{% for name in names[1...] %}[{{ name.id.stringify }}]{% end %}
    {% else %}
      {{ node }}
    {% end %}
  end
end
