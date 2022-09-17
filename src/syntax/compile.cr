module Aerotitan::Syntax
  def self.compile(input : String,
                   key : String,
                   fields : Array(String)) : Array(Context::Entry)
    tokens = Lexer.new(input).run
    nodes = Parser.new(tokens).run.select(Operator)

    validate_nodes nodes, key, fields
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

        unless names[1..].all? &.in?(fields)
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
    {% begin %}
      case op.symbol
      {% for symbol in Parser::VALID_OPERATORS %}
      {% not_equality = !{"==", "!="}.includes?(symbol) %}
      when {{ symbol }}
        Context::Entry.new do |data|
          left = if op.left.is_a?(Field)
            names = op.left.value.as(String).split('.')[1..]
            walk(data, names){% if not_equality %}.as_i.to_f{% end %}
          else
            op.left.value
          end{% if not_equality %}.as(Float64){% end %}

          right = if op.right.is_a?(Field)
            names = op.right.value.as(String).split('.')[1..]
            walk(data, names){% if not_equality %}.as_i.to_f{% end %}
          else
            op.right.value
          end{% if not_equality %}.as(Float64){% end %}

          left {{ symbol.id }} right
        end
      {% end %}
      else
        raise "unreachable"
      end
    {% end %}
  end

  private def self.walk(data : JSON::Any, keys : Array(String)) : JSON::Any
    if val = data[keys[0]]?
      if val.raw.is_a?(Hash)
        return walk val, keys[1..]
      else
        return val
      end
    end
    data # unreachable
  end
end
