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
        @value = identifier.to_sym
      end

      def eval(context)
        puts "needing #{@value}"
        context.get_variable(@value) || context.get_procedure(@value) || self
      end

      def inspect
        "#<Identifier::#{@value}>"
      end
    end
    
    class QuotedIdentifier
      attr_reader :value

      def initialize(identifier)
        @value = identifier
      end

      def inspect
        "#<QuotedIdentifier::#{@value}>"
      end
    end

    class Expression
      attr_reader :proc, :args

      def initialize(expression)
        @proc = expression[:proc]
        @args = expression[:args].empty? ? nil : expression[:args]
      end

      def eval(context)
        hash = @proc.eval(context)
        procedure, evaluate_car, arity = 
          hash[:implementation], hash[:evaluate_car], hash[:arity]

        raise "Called with wrong number of arguments (#{args.count} for #{arity})" unless args.count == arity

        args = @args.map do |arg|
          evaluate_car == true ? arg.eval(context)
                               : arg
        end

        procedure.call *args
      end

      def inspect
        "#<Expression @proc=#{@proc.inspect} @args=#{@args || 'nil'}>"
      end
    end

    class List
      attr_reader :elements

      def initialize(elements)
        @elements = elements
      end

      def inspect
        "#<List @elements=#{@elements}>"
      end
    end

    class QuotedList
      attr_reader :elements

      def initialize(elements)
        @elements = elements
      end

      def inspect
        "#<QuotedList @elements=#{@elements}>"
      end
    end

    class Vector
      attr_reader :elements

      def initialize(elements)
        @elements = elements
      end

      def inspect
        "#<Vector @elements=#{@elements}>"
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
