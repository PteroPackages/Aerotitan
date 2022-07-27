require "./node"

struct Context
  def initialize; end
end

class Interpreter
  property ctx    : Context
  property res    : Context
  property nodes  : Array(Node)
  property pos    : Int32
  property node   : Node

  def initialize(@ctx, @nodes)
    @res = Context.new
    @pos = 0
    @node = next_node
  end

  def current : Node
    @nodes[@pos]
  end

  def peek(count = 1) : Node
    @nodes[@pos + count]
  end

  def next_node : Node?
    @nodes[@pos += 1]?
  end

  def back_node : Node?
    @nodes[@pos - 1]?
  end

  def execute : Context
    loop do
      if node = next_node
        case @node = node
        when FieldNode  then visit_field
        when EqualsOp   then visit_op_eq
        else            next
        end
      else
        break
      end
    end
  end

  def resolve_node(node : Node) : Node
    return unless node.is_a? FieldNode
    # TODO
  end

  def visit_field : Nil
    # TODO
  end

  def visit_op_eq : Nil
    left = resolve_node back_node
    right = resolve_node next_node
    raise "missing left-side expression for equals" unless left
    raise "missing right-side expression for equals" unless right

    unless left.accepts? right
      raise "cannot compare type #{left.to_s} to type #{right.to_s}"
    end
  end
end
