# frozen_string_literal: true

module Autoflux
  module Step
    # The Agent is transfer control to the agent and wait for the next event
    class Agent
      attr_reader :prompt

      def initialize(prompt: nil)
        @prompt = prompt
      end

      def to_s = self.class.name || "Agent"

      def call(workflow:)
        workflow.agent.call(prompt, workflow: workflow)
        Command.new
      end
    end
  end
end
