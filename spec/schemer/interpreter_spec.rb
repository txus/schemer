require 'spec_helper'

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
          expression = "(define (square x) (* x x))(square 5)"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should == 25
        end
        it 'defines a function from a lambda' do
          expression = "(define square (lambda (x) (* x x)))(square 5)"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should == 25
        end
      end

      describe "#car" do
        it 'returns the first element from a list' do
          expression = "(car (x 3))"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should be_a(AST::Identifier)
        end
      end

      describe "#cdr" do
        it 'returns the last element from a list' do
          expression = "(cdr (x 3))"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should == 3
        end
      end

      describe "#cadr" do
        it 'returns the first element from the last element of a list' do
          expression = "(cadr (x (3 2)))"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should == 3
        end
      end

      describe "#caddr" do
        it 'returns the first element from the last element of the last element of a list' do
          expression = "(caddr (x (3 (1 2))))"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should == 1
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
            expression = "(null? 3)"
            lexer = Schemer::Lexer.new
            parser = Schemer::Parser.new
            ast = parser.apply(lexer.parse expression) 

            interpreter = Schemer::Interpreter.new(ast)
            interpreter.walk.should be_false
          end
        end
        context 'if the object is empty or nil' do
          it 'returns true' do
            expression = "(null? ())"
            lexer = Schemer::Lexer.new
            parser = Schemer::Parser.new
            ast = parser.apply(lexer.parse expression) 

            interpreter = Schemer::Interpreter.new(ast)
            interpreter.walk.should be_true
          end
        end
      end

      describe "#=" do
        it 'returns the equality of two arguments' do
          expression = "(= 3 (+ 1 2))"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should be_true
        end
      end

      describe "#eqv?" do
        it 'returns the equivalenc of two arguments' do
          expression = "(eqv? 3 (+ 1 2))"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should be_true
        end
      end

      describe "#<" do
        it 'returns true if foo is less than bar' do
          expression = "(< 3 (+ 2 2))"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should be_true
        end
      end

      describe "#>" do
        it 'returns true if foo is more than bar' do
          expression = "(> 3 (+ 2 2))"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should be_false
        end
      end

      describe "#cond" do
        it 'returns the first condition that evaluates to true' do
          expression = "(cond ((< 3 1) 9) ((>3 1) 7) )"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should == 7
        end
        it 'even if the result is an expression' do
          expression = "(cond ((< 3 1) 9) ((>3 8) 7) ((= 3 3) (+ 3 9)) )"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should == 12
        end
      end

    end

    describe "Regression tests from examples/ directory" do
      Dir["examples/*.scm"].each do |filename|
        file = File.read(filename)
        it "interprets #{filename}" do
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse file) 

          interpreter = Schemer::Interpreter.new(ast)
          expect {
            interpreter.walk
          }.to_not raise_error
        end
      end
    end

  end
end
