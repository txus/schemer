module Schemer
  module AST

    class Node
      def true?
        true
      end
      def false?
        !true?
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

      def inspect
        "#<QuotedIdentifier::#{@value}>"
      end
    end

    class Expression < Node
      attr_reader :proc, :args

      def initialize(expression)
        @proc = expression[:proc]
        @args = expression[:args].empty? ? nil : expression[:args].to_a
      end

      def eval(context)
        # Evaluate arguments
        arguments = nil
        arguments = args.map do |arg|
          if arg.is_a?(Identifier)
            arg = context.get_binding(arg.value) || arg
          else
            begin
              arg = arg.eval(context)
            rescue
              arg
            end
          end
        end if args

        # Evaluate proc
        if @proc.respond_to?(:value)
          block = context.get_binding(@proc.value)
        else
          block = @proc
        end

        block.call(*arguments)
      rescue NoMethodError=>e
        if e.message =~ /#{@proc.value}/
          raise "#{@proc.value} is not a defined procedure."
        else
          raise e
        end
      end

      def to_list
        List.new [@proc, @args].compact.flatten
      end

      def inspect
        "#<Expression @proc=#{@proc.inspect} @args=#{@args || 'nil'}>"
      end
    end

    class List < Node
      attr_reader :elements

      def initialize(elements)
        @elements = elements
      end

      def to_a
        @elements.to_a
      end

      def to_list
        self
      end

      def empty?
        @elements.empty?
      end

      def inspect
        "#<List @elements=#{@elements}>"
      end
    end

    class QuotedList < Node
      attr_reader :elements

      def initialize(elements)
        @elements = elements
      end

      def inspect
        "#<QuotedList @elements=#{@elements}>"
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
