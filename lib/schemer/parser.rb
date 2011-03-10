module Schemer
  class Parser < Parslet::Transform

    rule(:string => simple(:string))             { string }

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

    rule(:procedure => subtree(:procedure))      do
      puts procedure.inspect 
      if procedure[:proc].is_a?(AST::Identifier) && 
        procedure[:proc].value == :define &&
        procedure[:args].any?{|a| a.is_a?(AST::Procedure)}

        procedure[:args].map! do |arg|
          AST::List.new(arg.args)
        end
      end
      AST::Procedure.new(procedure)
    end

    rule(:comment => simple(:comment))           { AST::Comment.new(comment) }
    rule(:comment => [])                         { AST::Comment.new("") }

  end
end
