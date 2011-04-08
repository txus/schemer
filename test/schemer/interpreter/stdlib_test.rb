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

      assert_nil evaluated
    end

    def test_inspect_returns_the_object_as_string
      assert_evaluates "#<List [1, 3]>", "(inspect (1 3))"
    end

    def test_define_declares_a_variable
      ast = @parser.apply(@lexer.parse "(define number 3)") 
      interpreter = Schemer::Interpreter.new(ast)
      assert_nil interpreter.walk
      assert_equal 3, interpreter.env.get_binding(:number)
    end

    def test_define_declares_from_an_expression
      ast = @parser.apply(@lexer.parse "(define number (* 3 2))") 
      interpreter = Schemer::Interpreter.new(ast)
      assert_nil interpreter.walk
      assert_equal 6, interpreter.env.get_binding(:number)
    end

    def test_define_declares_a_function
      assert_evaluates 25, "(define (square x) (* x x))(square 5)"
    end

    def test_define_declares_a_function_edge_case
      ast = @parser.apply(@lexer.parse "(define (make-list x) (list 3 x))(make-list 5)")
      evaluated = Schemer::Interpreter.new(ast).walk

      assert_kind_of AST::List, evaluated
      assert_equal 3, evaluated.elements.first
      assert_equal 5, evaluated.elements.last
    end

    def test_define_declares_a_function_from_a_lambda
      assert_evaluates 25, "(define square (lambda (x) (* x x)))(square 5)"
    end

    def test_car_returns_the_first_element_of_a_list
      assert_evaluates 8, "(car (8 3))"
    end

    def test_cdr_returns_the_last_element_of_a_list
      assert_evaluates 3, "(cdr (9 3))"
    end

    def test_cadr_returns_the_first_of_the_last_element_of_a_list
      assert_evaluates 3, "(cadr (1 (3 2)))"
    end
    
    def test_caddr_returns_the_first_of_the_last_element_of_the_last_element_of_a_list
      assert_evaluates 1, "(caddr (8 (3 (1 2))))"
    end

    def test_list_converts_elements_to_a_list
      ast = @parser.apply(@lexer.parse "(list 3 4 x y)")
      evaluated = Schemer::Interpreter.new(ast).walk

      assert_kind_of AST::List, evaluated
      assert_equal 4, evaluated.elements.size
    end

    def test_null_returns_whether_the_object_is_nil
      assert_evaluates false, "(null? 3)"
    end

    def test_null_returns_whether_the_object_is_not_nil
      assert_evaluates true, "(null? ())"
    end
    
    def test_eq_operator_checks_for_equality
      assert_evaluates true, "(= 3 (+ 1 2))"
    end

    def test_eqv_operator_checks_for_equivalence
      assert_evaluates true, "(eqv? 3 (+ 1 2))"
    end

    def test_lower_than
      assert_evaluates true, "(< 3 (+ 2 2))"
    end

    def test_greater_than
      assert_evaluates false, "(> 3 (+ 2 2))"
    end

    def test_cond_returns_the_first_truthy_condition
      assert_evaluates 7, "(cond ((< 3 1) 9) ((>3 1) 7) )"
    end

    def test_cond_returns_the_first_truthy_condition_even_if_it_is_an_expression
      assert_evaluates 12, "(cond ((< 3 1) 9) ((>3 8) 7) ((= 3 3) (+ 3 9)) )"
    end

    private

    def assert_evaluates(expected, expression)
      ast = @parser.apply(@lexer.parse expression) 
      evaluated = Schemer::Interpreter.new(ast).walk

      assert_equal expected, evaluated
    end

  end
end
