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
    @node = uninitialized Node
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

    @res
  end

  def resolve_node(node : Node?) : Node
    return Nop.new() if node.nil?
    return node unless node.is_a? FieldNode

    value = @ctx.get_field node
    token = Token.new
    token.start = node.start
    token.end = node.end
    token.value = value.to_s

    case value
    when .is_a? Number
      NumberLiteral.new token.start, token.end
    when .is_a? String
      StringLiteral.new token
    when .is_a? Bool
      BoolLiteral.new token
    else
      raise "cannot parse value"
    end
  end

  private def ok?(node : Node) : Bool
    !node.nil? || !node.is_a?(Nop)
  end

  def visit_field : Nil
    # TODO
  end

  def visit_op_eq : Nil
    left = resolve_node back_node
    right = resolve_node next_node
    raise "missing left-side expression for equals" unless ok?(left)
    raise "missing right-side expression for equals" unless ok?(right)

    unless left.accepts? right
      raise "cannot compare type #{left.to_s} to type #{right.to_s}"
    end
  end
end
