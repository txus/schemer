module Schemer
  class Parser < Parslet::Transform

    rule(:string => simple(:string))     { string }

    rule(:integer => simple(:integer))    { integer.to_i }
    rule(:float => simple(:float))    { float.to_f }

    rule(:char => simple(:char))    { AST::CharacterLiteral.new(char) }

    rule(:boolean => simple(:boolean))    { boolean == 't' }

    rule(:identifier => simple(:identifier))    { AST::Identifier.new(identifier) }

    rule(:operator => simple(:operator)) do
      case operator
      when '+'
        AST::AddOperator.new
      when '-'
        AST::SubtractOperator.new
      when '*'
        AST::MultiplyOperator.new
      when '/'
        AST::DivideOperator.new
      when '>'
        AST::GtOperator.new
      when '<'
        AST::LtOperator.new
      when '='
        AST::EqualOperator.new
      end
    end

    rule(:expression => subtree(:expression)) { AST::Expression.new(expression) }

  end
end
