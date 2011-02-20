require 'spec_helper'

module Schemer
  describe Lexer do
    subject { Lexer.new }

    its(:lparen) { should parse('( ') }
    its(:rparen) { should parse(' )') }
    its(:space) { should parse("  \n") }

    its(:text) { should parse(' this should be treated as text!! oh yeah I think it should    ') }
    its(:text) { should parse('and without trimmable whitespace!!') }

    its(:symbol) { should parse('some_symbol') }
    its(:symbol) { should parse('s423-ome_symbol') }
    its(:symbol) { should parse('s423-ome_symbol?') }
    its(:quoted_symbol) { should parse('\'s423-ome_symbol?') }

    its(:string) { should_not parse("'single-quoted string'") }
    its(:string) { should_not parse(%q{'some " complex string'}) }
    its(:string) { should parse(%q{"some ' complex string"}) }

    its(:args) { should parse('arg1 arg2 "arg3"') }
    its(:args) { should parse("arg1 arg2\n \"arg3\"") }

    its(:comment) { should parse('; some comment!! "whoo"') }
    its(:comment) { should parse(';; some comment!! "whoo"') }
    its(:comment) { should parse(';;; some comment!! "whoo"') }

    its(:integer) { should parse('123') }
    its(:float) { should parse('99.9') }

    its(:literal) { should parse('123').as(:integer => '123') }
    its(:literal) { should parse('99.9').as(:float => '99.9') }
    its(:literal) { should parse('"hey"').as(:string => 'hey') }
    its(:literal) { should parse('#\z').as(:char => 'z') }
    its(:literal) { should parse('#t').as(:boolean => 't') }

    its(:quote) { should parse("'(1 2 3)") }
    its(:quote) { should parse("'()") }
    its(:vector) { should parse("#(1 '(2 4) 3)") }

    its(:pair) { should parse('(1 . 2)') }
    its(:pair) { should parse('(1 . (2 3))') }

    its(:list) { should parse('(1 2 3)') }
    its(:list) { should parse('()') }
    its(:list) { should parse('( )') }

    its(:expression) { should parse('(define some "string" #t)') }
    its(:expression) { should parse(%q{((lambda some arg) (get_some_proc) yeah "string" ((proc-proc) "another-string"))}) }
    its(:expression) { should parse('((lambda) "foo")') }
    its(:expression) { should parse("((lambda) (1 2 3))") }
    its(:expression) { should parse("((lambda) '(1 2 3))") }
    its(:expression) { should parse('((lambda) (bar))') }
    its(:expression) { should parse('(lambda (define zara \'zara) (write (eqv? zara \'zara)))') }
    its(:expression) { should(parse("(lambda (define (make-new-set?) '()) (define (make-new-set?) '(2 3)))").as do |output|
      output[:expression][:args].should have(2).expressions
      output[:expression][:args].first[:expression][:args].should include(:quoted_list => {:args => []})
      output[:expression][:args].last[:expression][:args].should include(:quoted_list => {:args => [{:integer =>"2"}, {:integer => "3"}]})
    end) }

    # Regression tests

    describe "Regression tests from examples/ directory" do
      Dir["examples/*.scm"].each do |filename|
        file = File.read(filename)
        it "tokenizes #{filename}" do
          subject.should parse(file)
        end
      end
    end

  end
end
