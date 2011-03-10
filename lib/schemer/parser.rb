module Schemer
  class Parser < Parslet::Transform

    rule(:string => simple(:string))            { AST::StringLiteral.new(string) }

    rule(:integer => simple(:integer))          { AST::IntegerLiteral.new(integer) }
    rule(:float => simple(:float))              { AST::FloatLiteral.new(float) }

    rule(:char => simple(:char))                { AST::CharacterLiteral.new(char) }

    rule(:boolean => simple(:boolean))          { boolean == 't' ? AST::TrueLiteral.new : AST::FalseLiteral.new }

    rule(:identifier => 
           simple(:identifier))                 { AST::Identifier.new(identifier) }
    rule(:quoted_identifier => 
           simple(:quoted_identifier))          { AST::QuotedIdentifier.new(quoted_identifier) }

    rule(:list => sequence(:list))               { AST::List.new(list) }
    rule(:quoted_list => sequence(:quoted_list)) { AST::QuotedList.new(quoted_list) }
    rule(:vector => sequence(:vector))           { AST::Vector.new(vector) }
    rule(:pair => sequence(:pair))               { AST::List.new(pair) }

    rule(:procedure => subtree(:procedure))   { AST::Procedure.new(procedure) }

  end
end
