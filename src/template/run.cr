require "./lexer"
require "./parser"

tokens = Lexer.new(%(server.name = "test server")).run
nodes = Parser.new(tokens).run
pp nodes