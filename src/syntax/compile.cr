module Aerotitan::Syntax
  def self.compile(input : String,
                   key : String,
                   fields : Array(String)) : Array(Context::Entry)
    tokens = Lexer.new(input).run
    nodes = Parser.new(tokens).run.select &.is_a?(Operator)

    validate_nodes nodes, fields
    nodes.map { |n| create_entry(n) }
  end

  private def self.validate_nodes(nodes : Array(Operator),
                                  key : String,
                                  fields : Array(String)) : Nil
    nodes.each do |node|
      if node.left.is_a?(Field)
        names = node.left.value.split '.'

        unless names[0] == key
          raise "Unknown object '#{names[0]}'"
        end

        unless fields.includes?(names[1..])
          raise "Unknown field '#{names[1..]}' for object #{key}"
        end
      end

      if node.right.is_a?(Field)
        names = node.right.value.split '.'

        unless names[0] == key
          raise "Unknown object '#{names[0]}'"
        end

        unless fields.includes?(node.right.value)
          raise "Unknown field '#{names[1..]}' for object #{key}"
        end
      end
    end
  end

  private def self.create_entry(op : Operator) : Context::Entry
  end
end
