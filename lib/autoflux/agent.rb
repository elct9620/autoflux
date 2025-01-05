# frozen_string_literal: true

module Autoflux
  # The Agent is a abstract class to represent the adapter of the Language Model.
  class Agent
    # @rbs memory: Memory?
    def call(**)
      raise NotImplementedError
    end
  end
end
