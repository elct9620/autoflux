# frozen_string_literal: true

module Autoflux
  # The Agent is a abstract class to represent the adapter of the Language Model.
  class Agent
    # @rbs tools: Array<Tool>
    def initialize(tools: [])
      @_tools = tools
    end

    # @rbs name: String
    def tool?(name)
      @_tools.any? { |tool| tool.name == name }
    end

    # @rbs name: String
    def tool(name)
      @_tools.find { |tool| tool.name == name }
    end

    # @rbs memory: Memory?
    def call(**)
      raise NotImplementedError
    end
  end
end
