# frozen_string_literal: true

module Autoflux
  module Step
    # The Command step is used to get the user input.
    class Command
      def to_s = self.class.name || "Command"

      def call(workflow:)
        input = workflow.io.read
        return Stop.new if input.nil?

        # @type var event: event
        event = { type: Autoflux::EventType::COMMAND, payload: input }
        workflow.apply(event)
        Agent.new
      end
    end
  end
end
