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

    rule(:list)       { lparen >> args.as(:list) >> rparen }
    rule(:vector)     { `#` >> lparen >> args.as(:vector) >> rparen }
    rule(:quoted_list){ `'` >> lparen >> args.as(:quoted_list) >> rparen }

    rule(:pair)       { lparen >> (arg >> space >> dot >> space >> args).as(:pair) >> rparen }

    rule(:symbol)     { letter >> (letter | integer | special_symbol).repeat(0) }
    rule(:quoted_symbol) { `'` >> symbol.as(:quoted_identifier) }

    rule(:operator)   { [`+`, `-`, `*`, `/`, `>=`, `<=`, `>`, `<`, `=`].inject(:|) }

    rule(:arg)        { (symbol.as(:identifier) | quoted_list | literal | quoted_symbol | expression | pair | vector | list) }
    rule(:args)       { (arg >> space?).repeat }

    rule(:newline)    { str("\n") }
    rule(:comment)    { `;`.repeat(1,3) >> (`\n`.absnt? >> any).repeat.as(:comment) }
    rule(:expression) { (lparen >> (symbol.as(:identifier) | operator.as(:identifier) | expression).as(:proc) >> (space? >> args.as(:args)).maybe >> rparen).as(:expression) }

    rule(:body)       { (expression | comment | space).repeat(0) }
    root :body

  end
end
