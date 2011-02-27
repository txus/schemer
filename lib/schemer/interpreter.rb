module Schemer
  class Interpreter

    attr_reader :env

    def initialize(ast = nil)
      @ast = ast
      @env = Environment.new do |env|

        env.push_procedure(:+, lambda do |a, b| 
          a + b
        end)

        env.push_procedure(:-, lambda do |a, b| 
          a - b
        end)

        env.push_procedure(:*, lambda do |a, b| 
          a * b
        end)

        env.push_procedure(:/, lambda do |a, b| 
          a / b
        end)

        env.push_procedure(:write, lambda do |value| 
          $stdout.print value
          nil
        end)

        env.push_procedure(:define, lambda { |name, implementation| 
          if name.is_a?(AST::Expression) 
            names = name.args.map(&:value)
            puts implementation.inspect
            block = eval("lambda { |#{names.join(', ')}|
              environment = Environment.new do |env|
                #{names.each do |name|
                   'env.push_variable(:' + name.to_s + ', ' + name.to_s + ')' 
                  end}
              end
              implementation.eval(environment)
            }")
             
            env.push_procedure(name.proc.value, block)
          elsif name.is_a?(AST::Identifier)
            value = implementation.eval(env)
            env.push_variable(name.value, value)
          end
          nil
        }, false)

      end
    end

    def walk
      @ast.map do |node|
        node.eval @env
      end.last
    end

  end
end
