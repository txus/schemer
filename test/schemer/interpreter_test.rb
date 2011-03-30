require 'test_helper'

module Schemer
  class InterpreterTest < MiniTest::Unit::TestCase

    def setup
      @lexer = Lexer.new
      @parser = Parser.new
    end

    def test_walks_the_ast_visiting_every_node
      text = """
       (define (double num)
           (+ num num))

       (write (double 12))
      """

      ast = @parser.apply(@lexer.parse text)
      interpreter = Interpreter.new(ast)

      ast.each do |node|
        node.should_receive(:eval).with(kind_of(Environment))
      end

      interpreter.walk
    end


  end
end
