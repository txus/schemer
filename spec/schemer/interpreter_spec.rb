require 'spec_helper'
require 'pp'

module Schemer
  describe Interpreter do

    let(:lexer) { Lexer.new }
    let(:parser) { Parser.new }

    let(:text) { """
     (define (double num)
         (+ num num))

     (write (double 12))
    """ }

    it 'walks the AST visiting every node' do
      ast = parser.apply(lexer.parse text)
      interpreter = Interpreter.new(ast)

      ast.each do |node|
        node.should_receive(:eval).with(kind_of(Environment))
      end

      interpreter.walk
    end

    describe "builtin procedures" do

      it 'adds' do
        "(+ 3 4)".should evaluate_to(7)
      end

      it 'subtracts' do
        "(- 3 4)".should evaluate_to(-1)
      end

      it 'multiplies' do
        "(* 3 4)".should evaluate_to(12)
      end

      it 'divides' do
        "(/ 4 2)".should evaluate_to(2)
      end

      describe "#write" do
        it 'prints to the output' do
          $stdout.should_receive(:print).with(4)
          "(write 4)".should evaluate_to(nil)
        end
      end

      describe "#inspect" do
        it 'returns the object inspected' do
          "(inspect (1 3))".should evaluate_to("#<List [1, 3]>")
        end
      end

      describe "#define" do
        it 'defines a variable' do
          expression = "(define number 3)"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should be_nil
          interpreter.env.get_binding(:number).should == 3
        end
        it 'defines a variable from an expression' do
          expression = "(define number (* 3 2))"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should be_nil
          interpreter.env.get_binding(:number).should == 6
        end
        it 'defines a function' do
          "(define (square x) (* x x))(square 5)".should evaluate_to(25)
        end
        it 'defines a function (edge case)' do
          expression = "(define (make-list x) (list 3 x))(make-list 5)"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          result = interpreter.walk
          result.should be_an(AST::List)
          result.elements.first.should eq(3)
          result.elements.last.should eq(5)
        end
        it 'defines a function from a lambda' do
          "(define square (lambda (x) (* x x)))(square 5)".should evaluate_to(25)
        end
      end

      describe "#car" do
        it 'returns the first element from a list' do
          "(car (8 3))".should evaluate_to(8)
        end
      end

      describe "#cdr" do
        it 'returns the last element from a list' do
          "(cdr (9 3))".should evaluate_to(3)
        end
      end

      describe "#cadr" do
        it 'returns the first element from the last element of a list' do
          "(cadr (1 (3 2)))".should evaluate_to(3)
        end
      end

      describe "#caddr" do
        it 'returns the first element from the last element of the last element of a list' do
          "(caddr (8 (3 (1 2))))".should evaluate_to(1)
        end
      end

      describe "#list" do
        it 'converts elements to a list' do
          expression = "(list 3 4 x y)"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          output = interpreter.walk
          output.should be_a(AST::List)
          output.should have(4).elements
        end
      end

      describe "#null?" do
        context 'if the object is nil' do
          it 'returns true' do
            "(null? 3)".should evaluate_to(false)
          end
        end
        context 'if the object is empty or nil' do
          it 'returns true' do
            "(null? ())".should evaluate_to(true)
          end
        end
      end

      describe "#=" do
        it 'returns the equality of two arguments' do
          "(= 3 (+ 1 2))".should evaluate_to(true)
        end
      end

      describe "#eqv?" do
        it 'returns the equivalenc of two arguments' do
          "(eqv? 3 (+ 1 2))".should evaluate_to(true)
        end
      end

      describe "#<" do
        it 'returns true if foo is less than bar' do
          "(< 3 (+ 2 2))".should evaluate_to(true)
        end
      end

      describe "#>" do
        it 'returns true if foo is more than bar' do
          "(> 3 (+ 2 2))".should evaluate_to(false)
        end
      end

      describe "#cond" do
        it 'returns the first condition that evaluates to true' do
          "(cond ((< 3 1) 9) ((>3 1) 7) )".should evaluate_to(7)
        end
        it 'even if the result is an expression' do
          "(cond ((< 3 1) 9) ((>3 8) 7) ((= 3 3) (+ 3 9)) )".should evaluate_to(12)
        end
      end

    end

    it 'parses equality.scm' do
      file = File.read('examples/equality.scm')
      lexer = Schemer::Lexer.new
      parser = Schemer::Parser.new
      tokens = lexer.parse(file)
      ast = parser.apply(tokens) 

      interpreter = Schemer::Interpreter.new(ast)
      result = interpreter.walk
    end

    it 'parses func.scm' do
      file = File.read('examples/func.scm')
      lexer = Schemer::Lexer.new
      parser = Schemer::Parser.new
      tokens = lexer.parse(file)
      ast = parser.apply(tokens) 

      interpreter = Schemer::Interpreter.new(ast)
      result = interpreter.walk
    end

    it 'parses simple_func.scm' do
      file = File.read('examples/simple_func.scm')
      lexer = Schemer::Lexer.new
      parser = Schemer::Parser.new
      tokens = lexer.parse(file)
      ast = parser.apply(tokens) 

      interpreter = Schemer::Interpreter.new(ast)
      result = interpreter.walk
    end

  end
end
