require "./node"

struct Context
end

class Interpreter
  property ctx    : Context
  property nodes  : Array(Node)
  property pos    : Int32
  property node   : Node

  def initialize(@ctx, @nodes)
    @pos = 0
    @node = next_node
  end

  def current_node
    @nodes[@pos]
  end

  def can_peek?
    @nodes[@pos+1]? != nil
  end

  def peek_node
    @node[@pos+1]
  end

  def next_node
    @node[@pos += 1]
  end

  def execute
    visit_field
  end

  def visit_field
    case @token.kind
    when Kind::Field then visit_field
    when Kind::
  end

  def visit_field
    # TODO
  end

  def visit_op_eq
  end
end
