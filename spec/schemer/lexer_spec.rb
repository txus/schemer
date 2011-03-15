require 'spec_helper'

module Schemer
  describe Lexer do
    subject { Lexer.new }

    its(:lparen) { should parse('( ') }
    its(:rparen) { should parse(' )') }
    its(:space)  { should parse("  \n") }

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

    its(:numeric) { should parse('123') }
    its(:numeric) { should parse('-123') }
    its(:numeric) { should parse('99.9') }
    its(:numeric) { should parse('-99.9') }

    its(:literal) { should parse('123').as(:integer => '123') }
    its(:literal) { should parse('-99.9').as(:float => '-99.9') }
    its(:literal) { should parse('"hey"').as(:string => 'hey') }
    its(:literal) { should parse('#\z').as(:char => 'z') }
    its(:literal) { should parse('#t').as(:boolean => 't') }

    its(:quoted_list) { should parse("'(1 2 3)") }
    its(:quoted_list) { should parse("'()") }
    its(:vector) { should parse("#(1 '(2 4) 3)") }

    its(:pair) { should parse('(1 . 2)') }
    its(:pair) { should parse('(1 . (2 3))') }

    its(:list) { should parse('(1 2 3)').as(:list => [{:integer => '1'}, {:integer => '2'}, {:integer => '3'}]) }
    its(:list) { should parse('()').as(:list => []) }
    its(:list) { should parse('( )').as(:list => []) }

    its(:list) { should parse('(define some "string" #t)') }
    its(:list) { should parse(%q{((lambda some arg) (get_some_proc) yeah "string" ((proc-proc) "another-string"))}) }
    its(:list) { should parse('((lambda) "foo")') }

    its(:list) { should(parse('(lambda x (+ x x))')) }

    its(:list) { should parse("((lambda) (1 2 3))") }
    its(:list) { should parse("((lambda) '(1 2 3))") }
    its(:list) { should parse('((lambda) (bar))') }
    its(:list) { should parse('(lambda (define zara \'zara) (write (eqv? zara \'zara)))') }
    its(:list) { should(parse("(lambda (define (make-new-set?) '()) (define (make-new-set?) '(2 3)))").as do |output|
      output[:list].should have(2).lists
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
