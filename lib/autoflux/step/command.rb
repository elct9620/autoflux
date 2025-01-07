# frozen_string_literal: true

module Autoflux
  module Step
    # The Command step is used to get the user input.
    class Command
      EXIT_COMMAND = "exit"

      def name = self.class.name || "Command"

      def call(workflow:)
        input = workflow.io.read
        return Stop.new if input.nil?
        return Stop.new if input == EXIT_COMMAND

        workflow.memory.push(role: :user, content: input)
        Assistant.new
      end
    end
  end
end
