# frozen_string_literal: true

module Autoflux
  # The Assistant state is used to call the agent.
  class Assistant
    OUTPUT_ROLE_NAME = "assistant"

    def call(workflow:)
      res = workflow.agent.call(memory: workflow.memory)
      workflow.memory.push(res)
      return Tools.new if res["tool_calls"]&.any?

      workflow.io.write(res["content"]) if res["role"] == OUTPUT_ROLE_NAME

      User.new
    end
  end
end
