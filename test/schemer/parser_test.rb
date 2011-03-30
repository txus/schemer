require 'test_helper'

module Schemer
  class ParserTest < MiniTest::Unit::TestCase
    def setup
      @lexer = Lexer.new
      @parser = Parser.new
    end

    def test_strings_suffer_no_change
      text = "(proc \"my string\")"
      parsed = parse(text).first.elements.last
      assert_equal "my string", parsed
    end

    def test_integers_are_typecasted
      text = "(proc 29)"
      parsed = parse(text).first.elements.last
      assert_equal 29, parsed
    end

    def test_floats_are_typecasted
      text = "(proc 29.42)"
      parsed = parse(text).first.elements.last
      assert_equal 29.42, parsed
    end

    def test_chars_are_transformed_into_character_literals
      text = "(proc #\\z)"
      parsed = parse(text).first.elements.last
      assert_instance_of AST::CharacterLiteral, parsed
    end

    def test_booleans_are_directly_evaluated
      text = "(proc #f #t)"
      parsed = parse(text).first.elements
      assert_equal false, parsed[1]
      assert_equal true,  parsed[2]
    end

    def test_identifiers
      text = "(proc my_identifier)"
      parsed = parse(text).first.elements.last
      assert_instance_of AST::Identifier, parsed
    end

    def test_quoted_identifiers
      text = "(proc 'quoted_identifier)"
      parsed = parse(text).first.elements.last
      assert_instance_of AST::QuotedIdentifier, parsed
    end

    def test_lists
      text = "(lambda (1 2 3))"
      parsed = parse(text).first.elements.last
      assert_instance_of AST::List, parsed
      assert_equal 1, parsed.elements[0]
      assert_equal 2, parsed.elements[1]
      assert_equal 3, parsed.elements[2]
    end

    def test_quoted_lists
      text = "(lambda '(1 2 3))"
      parsed = parse(text).first.elements.last
      assert_instance_of AST::QuotedList, parsed
      assert_equal 1, parsed.elements[0]
      assert_equal 2, parsed.elements[1]
      assert_equal 3, parsed.elements[2]
    end

    def test_vector
      text = "(lambda #(1 2 3))"
      parsed = parse(text).first.elements.last
      assert_instance_of AST::Vector, parsed
      assert_equal 1, parsed.elements[0]
      assert_equal 2, parsed.elements[1]
      assert_equal 3, parsed.elements[2]
    end

    def test_pairs_are_combined_into_lists
      text = "(lambda (1 . (2 3)))"
      parsed = parse(text).first.elements.last
      assert_equal 1, parsed.elements.first
      assert_instance_of AST::List, parsed.elements.last
      assert_equal 2, parsed.elements.last.elements[0]
      assert_equal 3, parsed.elements.last.elements[1]
    end

    private

    def parse(input)
      @parser.apply(@lexer.parse input)
    end
  end
end
