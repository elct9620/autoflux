# frozen_string_literal: true

module Autoflux
  module Step
    # The Assistant state is used to call the agent.
    class Assistant
      def to_s = self.class.name || "Assistant"

      def call(workflow:)
        event = workflow.agent.call(workflow: workflow)
        workflow.memory.push(event)

        # @type var invocation_event: Autoflux::invocationEvent
        invocation_event = event
        return Tool.new if invocation_event[:invocations]&.any?

        # @type var event: Autoflux::textEvent
        workflow.io.write(event[:content]) if event[:role] == ROLE_ASSISTANT

        Command.new
      end
    end
  end
end
