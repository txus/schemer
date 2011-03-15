module Schemer
  class Parser < Parslet::Transform

    rule(:string => simple(:string))             { string.to_s }

    rule(:integer => simple(:integer))           { integer.to_i }
    rule(:float => simple(:float))               { float.to_f }

    rule(:char => simple(:char))                 { AST::CharacterLiteral.new(char) }

    rule(:boolean => simple(:boolean))           { boolean == 't' }

    rule(:identifier => 
           simple(:identifier))                  { AST::Identifier.new(identifier) }
    rule(:quoted_identifier => 
           simple(:quoted_identifier))           { AST::QuotedIdentifier.new(quoted_identifier) }

    rule(:list => sequence(:list))               { AST::List.new(list) }
    rule(:quoted_list => sequence(:quoted_list)) { AST::QuotedList.new(quoted_list) }
    rule(:vector => sequence(:vector))           { AST::Vector.new(vector) }
    rule(:pair => sequence(:pair))               { AST::List.new(pair) }

    rule(:comment => simple(:comment))           { AST::Comment.new(comment) }
    rule(:comment => [])                         { AST::Comment.new("") }

  end
end
