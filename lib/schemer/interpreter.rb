module Schemer
  class Interpreter

    attr_reader :env

    def initialize(ast = nil)
      @ast = ast
      @env = Environment.new do |env|

        env.add_binding(:+, lambda do |a, b| 
          a + b
        end)

        env.add_binding(:-, lambda do |a, b| 
          a - b
        end)

        env.add_binding(:*, lambda do |a, b| 
          a * b
        end)

        env.add_binding(:/, lambda do |a, b| 
          a / b
        end)

        env.add_binding(:write, lambda do |value| 
          $stdout.print value
          nil
        end)

        env.add_binding(:define, lambda do |args, block|
          if args.is_a?(AST::Identifier)
            env.add_binding(args.value, block)
            return nil
          end
          original_args = args.to_list.to_a
          name = original_args.shift

          env.add_binding(name.value, lambda do |*args|
            environment = Environment.new(env)
            args.each_with_index do |arg, idx|
              environment.add_binding(original_args[idx].value, arg.eval(environment))
            end
            block.eval(environment)
          end)
          nil
        end)

      end
    end

    def walk
      @ast.map do |node|
        node.eval @env
      end.last
    end

  end
end
