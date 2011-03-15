module Schemer
  class Interpreter

    attr_reader :env

    def initialize(ast = nil)
      @ast = ast
      @env = Environment.new do |env|

        env.add_binding(:+, lambda do |cxt, a, b|
          a.eval(cxt) + b.eval(cxt)
        end)

        env.add_binding(:-, lambda do |cxt, a, b| 
          a.eval(cxt) - b.eval(cxt)
        end)

        env.add_binding(:*, lambda do |cxt, a, b| 
          a.eval(cxt) * b.eval(cxt)
        end)

        env.add_binding(:/, lambda do |cxt, a, b| 
          a.eval(cxt) / b.eval(cxt)
        end)

        env.add_binding(:write, lambda do |cxt, value| 
          $stdout.print value.eval(cxt)
          nil
        end)

        env.add_binding(:inspect, lambda do |cxt, object|
          object.eval(cxt).inspect
        end)

        env.add_binding(:define, lambda do |cxt, parameters, body|
          if parameters.is_a?(AST::Identifier)
            binded_value = if body.literal?
                body
              else
                body.eval(cxt)
              end
            cxt.add_binding(parameters.value, binded_value)
            return nil
          end

          parameters = parameters.to_a
          name = parameters.shift.value

          cxt.add_binding(name, lambda do |context, *params|
            context = Environment.new(context) 

            params.each_with_index do |param, idx|
              context.add_binding(parameters[idx].value, param.eval(context))
            end
            body.eval(context)

          end)

          nil
        end)

        env.add_binding(:lambda, lambda do |cxt, parameters, body|

          parameters = parameters.to_a

          lambda do |context, *params|
            context = Environment.new(context) 

            params.each_with_index do |param, idx|
              context.add_binding(parameters[idx].value, param.eval(context))
            end
            body.eval(context)
          end
        end)

        env.add_binding(:car, lambda do |cxt, list|
          list.eval(cxt).to_a.first
        end)

        env.add_binding(:cdr, lambda do |cxt, list|
          list.eval(cxt).to_a.last
        end)

        env.add_binding(:cadr, lambda do |cxt, list|
          list.eval(cxt).to_a.last.elements.first
        end)

        env.add_binding(:caddr, lambda do |cxt, list|
          puts "evaling caddr #{list.inspect}"
          puts list.eval(cxt).to_a.inspect
          list.eval(cxt).to_a
        end)

        env.add_binding(:list, lambda do |cxt, *args|
          args.map! do |arg|
            arg.eval(cxt)
          end
          AST::List.new(args)
        end)

        env.add_binding(:null?, lambda do |cxt, object|
          obj = object.eval(cxt)
          (obj.respond_to?(:empty?) && obj.empty?) || obj.nil?
        end)

        env.add_binding("=", lambda do |cxt, one, another|
          one.eval(cxt) == another.eval(cxt)
        end)

        env.add_binding(:eqv?, lambda do |cxt, one, another|
          one.eval(cxt) == another.eval(cxt)
        end)

        env.add_binding(:>, lambda do |cxt, one, another|
          one.eval(cxt) > another.eval(cxt)
        end)

        env.add_binding(:<, lambda do |cxt, one, another|
          one.eval(cxt) < another.eval(cxt)
        end)

        env.add_binding(:cond, lambda do |cxt, *conditions|
          conditions.map!(&:to_a)
          conditions.each do |condition, result|
            return result.eval(cxt) if condition.eval(cxt)
          end
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
