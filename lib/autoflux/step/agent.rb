# frozen_string_literal: true

module Autoflux
  module Step
    # The Agent is transfer control to the agent and wait for the next event
    class Agent
      def to_s = self.class.name || "Agent"

      def call(workflow:)
        event = workflow.agent.call(workflow: workflow)
        workflow.apply(event)
        Command.new
      end
    end
  end
end
