require 'spec_helper'

module Schemer
  describe Lexer do
    subject { Lexer.new }

    its(:lparen) { should parse('(') }
    its(:rparen) { should parse(')') }
    its(:space) { should parse("  \n") }

    its(:text) { should parse(' this should be treated as text!! oh yeah I think it should    ') }
    its(:text) { should parse('and without trimmable whitespace!!') }

    its(:symbol) { should parse('some_symbol') }
    its(:symbol) { should parse('s423-ome_symbol') }

    its(:string) { should parse("'single-quoted string'") }
    its(:string) { should parse(%q{'some " complex string'}) }
    its(:string) { should parse(%q{"some ' complex string"}) }

    its(:args) { should parse('arg1 arg2 "arg3"') }

    its(:comment) { should parse('; some comment!! "whoo"') }
    its(:comment) { should parse(';; some comment!! "whoo"') }
    its(:comment) { should parse(';;; some comment!! "whoo"') }

    its(:literal) { should parse('123') }
    its(:literal) { should parse('99.9') }
    its(:literal) { should parse('"hey"') }
    its(:literal) { should parse('#\z') }
    its(:literal) { should parse('#t') }

    its(:quote) { should parse("'(1 2 3)") }
    its(:list) { should parse('(1 2 3)') }

    its(:expression) { should parse('(define some "string" #t)') }
    its(:expression) { should parse(%q{((lambda some arg) (get_some_proc) yeah "string" ((proc-proc) 'another-string'))}) }
    its(:expression) { should parse("((lambda) 'foo')") }
    its(:expression) { should parse('((lambda) (bar))') }

  end
end
