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
      describe "Regular identifiers" do
        it "are transformed into Identifiers" do
          text = "(proc my_identifier)"
          parsed = subject.apply(lexer.parse text).first.args
          parsed.first.should be_an(AST::Identifier)
        end
      end

      describe "Quoted identifiers" do
        it "are transformed into QuotedIdentifiers" do
          text = "(proc 'quoted_identifier)"
          parsed = subject.apply(lexer.parse text).first.args
          parsed.first.should be_an(AST::QuotedIdentifier)
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

    describe "Lists" do
      describe "Regular lists" do
        it 'are transformed into Lists' do
          text = "(lambda (1 2 3))"
          parsed = subject.apply(lexer.parse text).first.args.first
          parsed.should be_an(AST::List)
          parsed.elements.should == [1, 2, 3]
        end
      end
      describe "Quoted lists" do
        it 'are transformed into QuotedLists' do
          text = "(lambda '(1 2 3))"
          parsed = subject.apply(lexer.parse text).first.args.first
          parsed.should be_an(AST::QuotedList)
          parsed.elements.should == [1, 2, 3]
        end
      end
      describe "Vectors" do
        it 'are transformed into Vectors' do
          text = "(lambda #(1 2 3))"
          parsed = subject.apply(lexer.parse text).first.args.first
          parsed.should be_an(AST::Vector)
          parsed.elements.should == [1, 2, 3]
        end
      end
      describe "Pairs" do
        it 'are combined into Lists' do
          text = "(lambda (1 . (2 3)))"
          parsed = subject.apply(lexer.parse text).first.args.first
          parsed.should be_an(AST::List)
          parsed.elements.first.should == 1
          parsed.elements.last.should be_an(AST::List)
          parsed.elements.last.elements.should == [2, 3]
        end
      end
    end

  end
end
