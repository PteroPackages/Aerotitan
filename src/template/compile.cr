module Aero::Template
  extend self

  struct Result
    getter? value : Bool

    def initialize(@procs : Array(JSON::Any -> Bool))
      @value = true
    end

    def initialize(@value : Bool)
      @procs = [] of JSON::Any -> Bool
    end

    def execute(data : JSON::Any) : Bool
      @procs.all? &.call(data)
    end
  end

  def compile(input : String?, key : String, model : Models::Fields) : Result
    return Result.new(false) unless input

    tokens = Lexer.new(input).run
    nodes = Parser.new(tokens).run.select(Operator)

    validate_nodes nodes, key, model
    Result.new nodes.map { |n| create_result_proc(n) }
  end

  private def validate_nodes(nodes : Array(Operator), key : String, model : Models::Fields) : Nil
    nodes.each do |node|
      if node.left.is_a?(Field)
        field = node.left.value.as(String)

        unless field.starts_with? key
          raise FieldError.new("Unknown object '#{field.split('.').first}'", node.left.start, node.left.stop)
        end

        unless model.has_key? field
          raise FieldError.new("Unknown field '#{field}' for object #{key}", node.left.start, node.left.stop)
        end
      end

      if node.right.is_a?(Field)
        field = node.right.value.as(String)

        unless field.starts_with? key
          raise FieldError.new("Unknown object '#{field.split('.').first}'", node.right.start, node.right.stop)
        end

        unless model.has_key? field
          raise FieldError.new("Unknown field '#{field}' for object #{key}", node.right.start, node.right.stop)
        end
      end

      left_value = node.left.is_a?(Field) ? model[node.left.value].default : node.left
      right_value = node.right.is_a?(Field) ? model[node.right.value].default : node.right

      compare_values node.kind, left_value, right_value
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

  private def create_result_proc(op : Operator) : JSON::Any -> Bool
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
        ->(data : JSON::Any) : Bool do
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
    raise "unreachable"
  end
end
