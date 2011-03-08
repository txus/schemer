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

        env.add_binding(:define, lambda do |parameters, body|
          if parameters.is_a?(AST::Identifier)
            # We are declaring a variable. We must eager-evaluate the value.
            result = if body.is_a?(AST::Expression)
              body.eval(env)
            else
              body
            end
            env.add_binding(parameters.value, result)
            return nil
          end
          original_params = parameters.to_list.to_a
          name = original_params.shift

          env.add_binding(name.value, lambda do |*args|
            # Create a new scope
            environment = Environment.new(env)
            args.each_with_index do |arg, idx|
              environment.add_binding(original_params[idx].value, arg.eval(environment))
            end
            body.eval(environment)
          end)
          nil
        end)

        env.add_binding(:lambda, lambda do |parameters, body|
          original_params = parameters.to_list.to_a
          lambda do |*args|
            environment = Environment.new(env)
            args.each_with_index do |arg, idx|
              environment.add_binding(original_params[idx].value, arg.eval(environment))
            end
            body.eval(environment)
          end
        end)

        env.add_binding(:car, lambda do |list|
          list.to_list.elements.first
        end)

        env.add_binding(:cdr, lambda do |list|
          list.to_list.elements.last
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
