require 'spec_helper'

module Schemer
  describe Lexer do
    subject { Lexer.new}

    describe "Regression tests from examples/ directory" do
      Dir["examples/*.scm"].each do |filename|
        file = File.read(filename)
        it "tokenizes #{filename}" do
          subject.should parse(file)
        end
      end
    end
  end
end
