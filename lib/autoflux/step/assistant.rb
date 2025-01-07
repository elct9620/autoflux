# frozen_string_literal: true

module Autoflux
  module Step
    # The Assistant state is used to call the agent.
    class Assistant
      def name = self.class.name || "Assistant"

      def call(workflow:)
        event = workflow.agent.call(memory: workflow.memory)
        workflow.memory.push(event)
        return Tool.new if event&.invocations&.any?

        workflow.io.write(event.content) if event.assistant?

        Command.new
      end
    end
  end
end
