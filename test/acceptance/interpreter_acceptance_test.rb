require 'test_helper'

module Schemer
  class InterpreterAcceptanceTest < MiniTest::Unit::TestCase
    def test_interpreter_acceptance
      lexer = Lexer.new

      Dir["examples/equality.scm",
          "examples/func.scm",
          "examples/simple_func.scm"].each do |filename|
        file = File.read(filename)
        begin
          refute_nil lexer.parse(file)
        rescue Parslet::ParseFailed
          flunk "Interpreter could not run #{filename}."
        end
      end
    end
  end
end
