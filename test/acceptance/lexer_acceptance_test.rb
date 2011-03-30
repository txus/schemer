require 'test_helper'

module Schemer
  class LexerAcceptanceTest < MiniTest::Unit::TestCase
    def test_lexer_acceptance
      lexer = Lexer.new

      Dir["examples/*.scm"].each do |filename|
        file = File.read(filename)
        begin
          refute_nil lexer.parse(file)
        rescue Parslet::ParseFailed
          flunk "Lexer could not tokenize #{filename}."
        end
      end
    end
  end
end
