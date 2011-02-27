module Schemer
  class Environment

    def initialize(parent = nil)
      @variables = {}
      @procedures = {}
      @parent = parent
      yield self
    end

    def push_variable(name, value)
      @variables.update({ name => value })
    end

    def get_variable(name)
      if var = @variables[name]
        return var
      elsif ! @parent.nil?
        @parent.get_variable(name)
      else
        nil
      end
    end

    def get_procedure(name)
      if var = @procedures[name]
        return var
      elsif ! @parent.nil?
        @parent.get_procedure(name)
      else
        nil
      end
    end

    def push_procedure(function, implementation, evaluate_car = true)
      @procedures.update({ function => {:implementation => implementation, :evaluate_car => evaluate_car, :arity => implementation.arity} })
    end

  end
end
