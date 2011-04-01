require 'test_helper'

module Schemer
  class StandardLibraryTest < MiniTest::Unit::TestCase

    def setup
      @lexer = Lexer.new
      @parser = Parser.new
    end

    def test_add
      assert_evaluates 7, "(+ 3 4)"
    end

    def test_subtracts
      assert_evaluates -1, "(- 3 4)"
    end

    def test_multiplies
      assert_evaluates 12, "(* 3 4)"
    end

    def test_divides
      assert_evaluates 2, "(/ 4 2)"
    end

    def test_write_prints_to_stdout
      $stdout.expects(:print).with(4)

      ast = @parser.apply(@lexer.parse "(write 4)") 
      evaluated = Schemer::Interpreter.new(ast).walk

      assert_equal nil, evaluated
    end

    def test_inspect_returns_the_object_as_string
      assert_evaluates "#<List [1, 3]>", "(inspect (1 3))"
    end

    private

    def assert_evaluates(expected, expression)
      ast = @parser.apply(@lexer.parse expression) 
      evaluated = Schemer::Interpreter.new(ast).walk

      assert_equal expected, evaluated
    end

  end
end
