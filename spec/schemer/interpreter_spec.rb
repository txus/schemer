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
        pending 'defines a variable' do
          expression = "(define number 3)"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          interpreter = Schemer::Interpreter.new(ast)
          interpreter.walk.should be_nil
          interpreter.env.get_variable(:number).should == 3
        end
        it 'defines a procedure' do
          expression = "(define (double num) (+ num 4)) (double 3)"
          lexer = Schemer::Lexer.new
          parser = Schemer::Parser.new
          ast = parser.apply(lexer.parse expression) 

          puts ast.inspect

          interpreter = Schemer::Interpreter.new(ast)
          returned = interpreter.walk

          procedure =  interpreter.env.get_procedure(:double)
          procedure.should be_a_kind_of(Hash)
          procedure[:implementation].should be_a_kind_of(Proc)
          procedure[:arity].should == 1
          procedure[:evaluate_car].should be_true

          returned.should be_nil
        end
      end

    end

  end
end
