module Schemer
  class Lexer < Parslet::Parser
    alias_method :`, :str

    rule(:space)      { match('\s').repeat(1) }
    rule(:space?)     { space.maybe }

    rule(:lparen)     { `(` >> space? }
    rule(:rparen)     { space? >> `)` }

    rule(:text)       { any.repeat }

    rule :single_quote_string do
      `'` >> (`''` | `'`.absnt? >> any).repeat.as(:string) >> `'`
    end

    rule :double_quote_string do
      `"` >> (`""` | `"`.absnt? >> any).repeat.as(:string) >> `"`
    end

    rule(:string)     { double_quote_string }

    rule(:letter)     { match('[a-zA-Z]') }
    rule(:dot)       { `.` } 
    rule(:special_symbol) { `_` | `-` | `?` | `!` | `*` }


    rule(:integer)    { match('\d').repeat(1) }
    rule(:float)      { integer.repeat(1) >> dot >> integer.repeat(1) }
    rule(:numeric)    { float.as(:float) | integer.as(:integer) }

    rule(:character)  { `#\\` >> letter.as(:char) }
    rule(:boolean)    { `#` >> (`t` | `f`).as(:boolean) }
    rule(:literal)    { numeric | string | character | boolean }

    rule(:quote)      { `'` >> list.as(:quoted_list) }
    rule(:vector)     { `#` >> list.as(:vector) }
    rule(:list)       { lparen >> args >> rparen }
    rule(:pair)       { lparen >> arg >> space >> dot >> space >> args >> rparen }

    rule(:symbol)     { letter >> (letter | integer | special_symbol).repeat(0) }
    rule(:quoted_symbol) { `'` >> symbol.as(:quoted_identifier) }

    rule(:operator)   { [`+`, `-`, `*`, `/`, `>=`, `<=`, `>`, `<`, `=`].inject(:|) }


    rule(:arg)        { (symbol.as(:identifier) | quote | literal | quoted_symbol | expression | pair | vector | list) }
    rule(:args)       { (arg >> space?).repeat.as(:args) }

    rule(:newline)    { str("\n") }
    rule(:comment)    { `;`.repeat(1,3) >> (`\n`.absnt? >> any).repeat.as(:comment) }
    rule(:expression) { (lparen >> (symbol.as(:identifier) | operator.as(:operator) | expression).as(:proc) >> (space? >> args).maybe >> rparen).as(:expression) }

    rule(:body)       { (quote | expression | comment | space).repeat(0) }
    root :body

  end
end
