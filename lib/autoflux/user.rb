# frozen_string_literal: true

module Autoflux
  # The User state is used to get the user input.
  class User
    def call(workflow:)
      input = workflow.io.read
      workflow.memory.push(role: :user, content: input)

      Assistant.new
    end
  end
end
