# frozen_string_literal: true

module Autoflux
  # The State is abstract class to represent the interface of the state
  class State
    # @rbs workflow: Workflow
    def call(**)
      raise NotImplementedError
    end
  end
end
