# frozen_string_literal: true

module Autoflux
  module Step
    # The Tool state is used to call the tools provided by the agent.
    class Tool
      def to_s = self.class.name || "Tool"

      def call(workflow:)
        # @type var event: Autoflux::invocationEvent
        event = workflow.events.last
        event[:invocations]&.each do |invocation|
          # @type: var invocation: Autoflux::invocation
          # @type: var event: Autoflux::invocationResultEvent
          event = {
            role: ROLE_TOOL,
            content: run(workflow: workflow, invocation: invocation).to_json,
            invocation_id: invocation[:id]
          }
          workflow.events.push(event)
        end

        Assistant.new
      end

      protected

      def run(workflow:, invocation:)
        name = invocation[:name]
        params = JSON.parse(invocation[:args], symbolize_names: true)
        return { status: "error", message: "Tool not found" } unless workflow.agent.tool?(name)

        workflow.agent.tool(name)&.call(workflow: workflow, params: params)
      rescue JSON::ParserError
        { status: "error", message: "Invalid arguments" }
      end
    end
  end
end
