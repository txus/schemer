require 'test_helper'

module Schemer
  class LexerTest < MiniTest::Unit::TestCase
    def setup
      @lexer = Lexer.new
    end

    def test_lparen; tokenizes("( ");   end
    def test_rparen; tokenizes(' )');   end
    def test_space;  tokenizes("  \n"); end

    def test_symbol
      tokenizes('some_symbol')
      tokenizes('s423-ome_symbol')
      tokenizes('s423-ome_symbol?')
    end

    def test_quoted_symbol; tokenizes("'s423-ome_symbol?"); end

    def test_string
      does_not_tokenize("'single-quoted string'")      
      does_not_tokenize(%q('some " complex string'))
      tokenizes(%q("some ' complex string'"))
    end

    def test_args
      tokenizes('arg1 arg2 "arg3"')
      tokenizes("arg1 arg2\n  \"arg3\"")
    end

    def test_comment
      tokenizes('; some comment!! "whoo"')
      tokenizes(';; some comment!! "whoo"')
      tokenizes(';;; some comment!! "whoo"')
    end

    def test_numeric
      tokenizes('123')
      tokenizes('-123')
      tokenizes('99.9')
      tokenizes('-99.9')
    end

    def test_literal
      tokenizes('123',   as: { integer: '123' })
      tokenizes('-99.9', as: { float:   '-99.9' })
      tokenizes('"hey"', as: { string:  'hey' })
      tokenizes("#\\z",  as: { char:    'z' })
      tokenizes("#t",    as: { boolean: 't' })
    end

    def test_quoted_list
      tokenizes("'(1 2 3)")
      tokenizes("'()")
    end

    def test_vector; tokenizes("#(1 '(2 4) 3)"); end

    def test_pair
      tokenizes("(1 . 2)")
      tokenizes("(1 . (2 3))")
    end

    def test_list
      tokenizes('(1 2 3)', as: { list: [{integer: '1'}, {integer: '2'}, {integer: '3'}] })
      tokenizes('()', as: { list: [] })
      tokenizes('( )', as: { list: [] })
      tokenizes('(define some "string" #t)')
      tokenizes(%q{((lambda some arg) (get_some_proc) yeah "string" ((proc-proc) "another-string"))})
      tokenizes('((lambda) "foo")')
      tokenizes('(lambda (x) (+ x x))')
      tokenizes('((lambda) (1 2 3))')
      tokenizes("((lambda) '(1 2 3))")
      tokenizes("((lambda) (bar))")
      tokenizes("(lambda (define zara 'zara) (write (eqv? zara 'zara)))")
      tokenizes("(lambda (define (make-new-set?) '()) (define (make-new-set?) '(2 3)))")
    end

    private

    def tokenizes(input, options = {})
      as = options.delete(:as)
      caller.first.match /`(.*)\'/
      rule = $1.split("_")[1..-1].join("_").to_sym

      im = @lexer.send(rule).parse(input)

      as.nil? ? refute_nil(im)
              : assert_equal(as, im)
    rescue Parslet::ParseFailed
      flunk "#{rule} rule could not tokenize #{input}"
    end

    def does_not_tokenize(input)
      caller.first.match /`(.*)\'/
      rule = $1.split("_").last.to_sym

      assert_raises Parslet::ParseFailed do
        @lexer.send(rule).parse(input)
      end
    end
  end
end
