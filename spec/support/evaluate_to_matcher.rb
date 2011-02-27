RSpec::Matchers.define :evaluate_to do |result|
  match do |expression|
    @expression = expression
    lexer = Schemer::Lexer.new
    parser = Schemer::Parser.new
    ast = parser.apply(lexer.parse expression) 

    interpreter = Schemer::Interpreter.new(ast)
    @out = interpreter.walk
    @out.should == result
  end

  description do
    "evaluate \"#{@expression}\" to #{result}"
  end

  failure_message_for_should do |text|
    "expected \"#{@expression}\" to evaluate to #{result}, but it returned #{@out}"
  end

end
