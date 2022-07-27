require "./interpreter"
require "./lexer"
require "./parser"

tokens = Lexer.new(%(server.name = "test server")).run
nodes = Parser.new(tokens).run

ctx = Context.new
res = Interpreter.new(ctx, nodes).execute
pp! res
