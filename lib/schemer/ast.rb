module Schemer
  module AST

    class CharacterLiteral
      attr_reader :value

      def initialize(character)
        @value = character.bytes.first
      end

      def inspect
        "#<Char::#{@value}>"
      end
    end

    class Identifier
      attr_reader :value

      def initialize(identifier)
        @value = identifier
      end

      def inspect
        "#<Identifier::#{@value}>"
      end
    end

    class Expression
      attr_reader :proc, :args

      def initialize(expression)
        @proc = expression[:proc]
        @args = expression[:args].empty? ? nil : expression[:args]
      end

      def inspect
        "#<Expression @proc=#{@proc.inspect} @args=#{@args || 'nil'}>"
      end
    end

    class AddOperator
      def inspect
        "#<Operator::Add>"
      end
    end
    class SubtractOperator
      def inspect
        "#<Operator::Subtract>"
      end
    end
    class MultiplyOperator
      def inspect
        "#<Operator::Multiply>"
      end
    end
    class DivideOperator
      def inspect
        "#<Operator::Divide>"
      end
    end
    class GteOperator
      def inspect
        "#<Operator::GreaterThanOrEqual>"
      end
    end
    class GtOperator
      def inspect
        "#<Operator::GreaterThan>"
      end
    end
    class LteOperator
      def inspect
        "#<Operator::LowerThanOrEqual>"
      end
    end
    class LtOperator
      def inspect
        "#<Operator::LowerThan>"
      end
    end
    class EqualOperator
      def inspect
        "#<Operator::Equal>"
      end
    end

  end
end
