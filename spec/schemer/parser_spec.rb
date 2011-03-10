require 'spec_helper'

module Schemer
  describe Parser do
    subject { Parser.new }
    let(:lexer) { Lexer.new }

    describe "Strings" do
      it "suffer no change" do
        text = "(proc \"my string\")"
        parsed = subject.apply(lexer.parse text).first.args.first
        parsed.value.should eq("my string")
      end
    end

    describe "Integers" do
      it "are typecasted from string" do
        text = "(proc 29)"
        parsed = subject.apply(lexer.parse text).first.args.first
        parsed.value.should eq(29)
      end
    end

    describe "Floats" do
      it "are typecasted from string" do
        text = "(proc 29.42)"
        parsed = subject.apply(lexer.parse text).first.args.first
        parsed.value.should eq(29.42)
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
        parsed.first.value.should be_false
        parsed.last.value.should be_true
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
        parsed.should be_an(AST::Procedure)
        parsed.args.first.should be_an(AST::Procedure)
      end
    end

    describe "Lists" do
      describe "Regular lists" do
        it 'are transformed into Lists' do
          text = "(lambda (1 2 3))"
          parsed = subject.apply(lexer.parse text).first.args.first
          parsed.should be_an(AST::List)
          parsed.elements[0].value.should eq(1)
          parsed.elements[1].value.should eq(2)
          parsed.elements[2].value.should eq(3)
        end
      end
      describe "Quoted lists" do
        it 'are transformed into QuotedLists' do
          text = "(lambda '(1 2 3))"
          parsed = subject.apply(lexer.parse text).first.args.first
          parsed.should be_an(AST::QuotedList)
          parsed.elements[0].value.should eq(1)
          parsed.elements[1].value.should eq(2)
          parsed.elements[2].value.should eq(3)
        end
      end
      describe "Vectors" do
        it 'are transformed into Vectors' do
          text = "(lambda #(1 2 3))"
          parsed = subject.apply(lexer.parse text).first.args.first
          parsed.should be_an(AST::Vector)
          parsed.elements[0].value.should eq(1)
          parsed.elements[1].value.should eq(2)
          parsed.elements[2].value.should eq(3)
        end
      end
      describe "Pairs" do
        it 'are combined into Lists' do
          text = "(lambda (1 . (2 3)))"
          parsed = subject.apply(lexer.parse text).first.args.first
          parsed.should be_an(AST::List)
          parsed.elements.first.value.should == 1
          parsed.elements.last.should be_an(AST::List)
          parsed.elements.last.elements[0].value.should eq(2)
          parsed.elements.last.elements[1].value.should eq(3)
        end
      end
    end

  end
end
