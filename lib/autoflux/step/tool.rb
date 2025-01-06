# frozen_string_literal: true

module Autoflux
  module Step
    # The Tool state is used to call the tools provided by the agent.
    class Tool < Base
      def call(workflow:)
        workflow.memory.last["tool_calls"]&.each do |tool|
          workflow.memory.push(
            role: :tool,
            content: run(workflow: workflow, tool: tool).to_json,
            tool_call_id: tool["id"]
          )
        end

        Assistant.new
      end

      protected

      def run(workflow:, tool:)
        name = tool.dig("function", "name")
        params = JSON.parse(tool.dig("function", "arguments"), symbolize_names: true)
        return { status: "error", message: "Tool not found" } unless workflow.agent.tool?(name)

        workflow.agent.tool(name).call(**params)
      rescue JSON::ParserError
        { status: "error", message: "Invalid arguments" }
      end
    end
  end
end
