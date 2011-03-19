module Schemer
  module AST

    class Node
      def true?
        true
      end
      def false?
        !true?
      end
      def literal?
        false
      end
    end

    class Comment < Node
      attr_reader :value

      def initialize(comment)
        @value = comment
      end

      def eval(context)
      end

      def inspect
        "#<Comment::\"#{@value.inspect}\">"
      end
    end

    class CharacterLiteral < Node
      attr_reader :value

      def initialize(character)
        @value = character.to_s.bytes.first
      end

      def inspect
        "#<Char::#{@value}>"
      end

      def literal?
        true
      end
    end

    class Identifier < Node
      attr_reader :value

      def initialize(identifier)
        @value = identifier.to_sym
      end

      def eval(context)
        context.get_binding(@value)
      end

      def inspect
        "#<Identifier::#{@value}>"
      end
    end
    
    class QuotedIdentifier < Node
      attr_reader :value

      def initialize(identifier)
        @value = identifier
      end

      def eval(context)
        context.get_binding(@value)
      end

      def inspect
        "#<QuotedIdentifier::#{@value}>"
      end
    end

    class List < Node
      attr_reader :elements

      def initialize(elements)
        @elements = elements
      end

      def to_a
        @elements
      end

      def eval(context)
        cdr = @elements.clone
        car = cdr.shift

        if car.is_a?(Identifier)
          procedure = context.get_binding(car.value)
          if procedure
            return procedure.call(context, *cdr)
          else
            raise "UNKNOWN IDENTIFIER #{car.value}"
          end
        elsif car.is_a?(List)
          new_car = car.eval(context)
          if new_car.is_a?(Identifier)
            procedure = context.get_binding(car.value)
            if procedure
              return procedure.call(context, *cdr)
            else
              raise "UNKNOWN IDENTIFIER #{car.value}"
            end
          elsif new_car.is_a?(Proc)
            return new_car.call(context, *cdr)
          end
        else
          return self
        end
      end

      def empty?
        @elements.empty?
      end

      def inspect
        "#<List #{@elements}>"
      end
    end

    class QuotedList < List
      def eval(context)
        self
      end

      def inspect
        "#<QuotedList #{@elements}>"
      end
    end

    class Vector < Node
      attr_reader :elements

      def initialize(elements)
        @elements = elements
      end

      def inspect
        "#<Vector @elements=#{@elements}>"
      end
    end

  end
end
