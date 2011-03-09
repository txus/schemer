$: << 'lib'

require 'bundler'
Bundler.setup

require 'schemer'
require 'benchmark'

lexer = Schemer::Lexer.new

n = 100

text = File.read(File.expand_path('../examples/bintree.scm'))

Benchmark.bm do |x|
  x.report do
    n.times { lexer.parse text }
  end
end
