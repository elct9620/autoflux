# frozen_string_literal: true

module Autoflux
  # The User state is used to get the user input.
  class User
    EXIT_COMMAND = "exit"

    def call(workflow:)
      input = workflow.io.read
      return Stop.new if input == EXIT_COMMAND

      workflow.memory.push(role: :user, content: input)

      Assistant.new
    end
  end
end
