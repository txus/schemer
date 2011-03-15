module Schemer
  class Environment

    def initialize(parent = nil)
      @bindings = {}
      @parent = parent
      yield self if block_given?
    end

    def add_binding(name, value)
      @bindings.update({ name.to_s => value })
    end

    def get_binding(name)
      if got = @bindings[name.to_s]
        got
      elsif ! @parent.nil?
        @parent.get_binding(name)
      else
        nil
      end
    end

  end
end
