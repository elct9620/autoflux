# frozen_string_literal: true

module Autoflux
  module Step
    # The Assistant state is used to call the agent.
    class Assistant
      OUTPUT_ROLE_NAME = "assistant"

      def name = self.class.name || "Assistant"

      def call(workflow:)
        res = workflow.agent.call(memory: workflow.memory)
        workflow.memory.push(res)
        return Tool.new if res["tool_calls"]&.any?

        workflow.io.write(res["content"]) if res["role"] == OUTPUT_ROLE_NAME

        Command.new
      end
    end
  end
end
