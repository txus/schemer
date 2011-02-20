require 'spec_helper'

module Schemer
  describe Parser do
    subject { Parser.new }
    let(:lexer) { Lexer.new }

    describe "Strings" do
      it "suffer no change" do
        text = "(proc \"my string\")"
        parsed = subject.apply(lexer.parse text).first.args
        parsed.should include("my string")
      end
    end

    describe "Integers" do
      it "are typecasted from string" do
        text = "(proc 29)"
        parsed = subject.apply(lexer.parse text).first.args
        parsed.should include(29)
      end
    end

    describe "Floats" do
      it "are typecasted from string" do
        text = "(proc 29.42)"
        parsed = subject.apply(lexer.parse text).first.args
        parsed.should include(29.42)
      end
    end

    describe "Chars" do
      it "are transformed into CharacterLiterals" do
        text = "(proc #\\z)"
        parsed = subject.apply(lexer.parse text).first.args
        parsed.first.should be_an(AST::CharacterLiteral)
      end
    end

    describe "Booleans" do
      it "are directly evaluated" do
        text = "(proc #f #t)"
        parsed = subject.apply(lexer.parse text).first.args
        parsed.first.should eq(false)
        parsed.last.should eq(true)
      end
    end

    describe "Identifiers" do
      it "are transformed into Identifiers" do
        text = "(proc my_identifier)"
        parsed = subject.apply(lexer.parse text).first.args
        parsed.first.should be_an(AST::Identifier)
      end
    end

    describe "Operators" do
      it "are transformed into its kind on parsing time" do
        {
          "+"  => AST::AddOperator,
          "-"  => AST::SubtractOperator,
          "*"  => AST::MultiplyOperator,
          "/"  => AST::DivideOperator,
          ">=" => AST::GteOperator,
          "<=" => AST::LteOperator,
          ">"  => AST::GtOperator,
          "<"  => AST::LtOperator,
          "="  => AST::EqualOperator,
        }.each_pair do |operator, klass|
          parsed = subject.apply(lexer.parse "(#{operator} 3 4)").first.proc
          parsed.should be_a(klass)
        end
      end
    end

    describe "Expressions" do
      it "are transformed into Expressions recursively" do
        text = "(lambda (my-proc))"
        parsed = subject.apply(lexer.parse text).first
        parsed.should be_an(AST::Expression)
        parsed.args.first.should be_an(AST::Expression)
      end
    end

  end
end
