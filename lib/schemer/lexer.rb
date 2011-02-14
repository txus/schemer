module Schemer
  class Lexer < Parslet::Parser
    alias_method :`, :str

    rule(:lparen)     { `(` }
    rule(:rparen)     { `)` }

    rule(:space)      { match('\s').repeat(1) }
    rule(:space?)     { space.maybe }

    rule(:text)       { any.repeat }

    rule :single_quote_string do
      `'` >> (`''` | `'`.absnt? >> any).repeat.as(:string) >> `'`
    end

    rule :double_quote_string do
      `"` >> (`""` | `"`.absnt? >> any).repeat.as(:string) >> `"`
    end

    rule(:string)     { single_quote_string | double_quote_string }

    rule(:letter)     { match('[a-zA-Z]') }
    rule(:underscore) { `_` }
    rule(:dash)       { `-` }
    rule(:dot)        { `.` }
    rule(:number)     { match('\d') }
    rule(:numeric)    { number.repeat(1) >> (dot >> number.repeat(1)).maybe }

    rule(:character)  { `#\\` >> letter.as(:char) }
    rule(:boolean)    { `#` >> (`t` | `f`).as(:boolean) }
    rule(:literal)    { numeric.as(:numeric) | string | character | boolean }

    rule(:quote)      { `'` >> list.as(:quoted_list) }
    rule(:list)       { lparen >> (space? >> (symbol | literal | expression)).repeat(1) >> space? >> rparen }

    rule(:symbol)     { (letter >> (letter | underscore | dash | number).repeat(0)).as(:symbol) }

    rule(:operator)   { [`+`, `-`, `*`, `/`, `>`, `<`, `=`].inject(:|) }

    rule(:arg)        { (symbol | literal | expression | quote) }
    rule(:args)       { (arg >> space?).repeat.as(:args) }

    rule(:newline)    { str("\n") }
    rule(:comment)    { `;`.repeat(1,3) >> (`\n`.absnt? >> any).repeat.as(:comment) }
    rule(:expression) { (lparen >> space? >> (symbol | operator | expression).as(:proc) >> (space? >> args).maybe >> space? >> rparen).as(:expression) }

    rule(:body)       { (quote | expression | comment | space).repeat }
    root :body

  end
end
