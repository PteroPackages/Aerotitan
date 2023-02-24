module Aero::Template
  extend self

  struct Result
    def initialize(&@func : JSON::Any -> Bool)
    end

    def execute(data : JSON::Any) : Bool
      @func.call data
    end
  end

  def compile(input : String, key : String, model : Models::Fields) : Array(Result)
    tokens = Lexer.new(input).run
    nodes = Parser.new(tokens).run.select(Operator)

    validate_nodes nodes, key, model
    nodes.map { |n| create_entry(n) }
  end

  private def validate_nodes(nodes : Array(Operator), key : String, model : Models::Fields) : Nil
    nodes.each do |node|
      if node.left.is_a?(Field)
        field = node.left.value.as(String)

        unless field.starts_with? key
          raise SyntaxError.new("Unknown object '#{field.split('.').first}'", node.start, node.stop)
        end

        unless model.has_key? field
          raise SyntaxError.new("Unknown field '#{field}' for object #{key}", node.start, node.stop)
        end
      end

      if node.right.is_a?(Field)
        field = node.right.value.as(String)

        unless field.starts_with? key
          raise SyntaxError.new("Unknown object '#{field.split('.').first}'", node.start, node.stop)
        end

        unless model.has_key? field
          raise SyntaxError.new("Unknown field '#{field}' for object #{key}", node.start, node.stop)
        end
      end

      leftval = node.left.is_a?(Field) ? model[node.left.value].default : node.left
      rightval = node.right.is_a?(Field) ? model[node.right.value].default : node.right

      compare_values node.kind, leftval, rightval
    end
  end

  private def compare_values(kind : OpKind, left : Value, right : Value)
    case kind
    when OpKind::Eq, OpKind::Neq
      raise ComparisonError.new(kind, left, right) unless left.accepts? right
    else
      unless left.is_a?(NumberLiteral) && right.is_a?(NumberLiteral)
        raise ComparisonError.new(kind, left, right)
      end
    end
  end

  private def create_entry(op : Operator) : Result
    {% begin %}
      case op.kind
      {% for kind, symbol in {
                               :Eq  => "==",
                               :Neq => "!=",
                               :Lt  => "<",
                               :Lte => "<=",
                               :Gt  => ">",
                               :Gte => ">=",
                             } %}
      {% not_equality = !(kind == :Eq || kind == :Neq) %}
      when OpKind::{{ kind.id }}
        Result.new do |data|
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

  private def walk(data : JSON::Any, keys : Array(String)) : JSON::Any
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
