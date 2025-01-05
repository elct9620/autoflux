# frozen_string_literal: true

module Autoflux
  # The Assistant state is used to call the agent.
  class Assistant
    def call(workflow:)
      res = workflow.agent.call(memory: workflow.memory)
      workflow.memory.push(res)

      workflow.io.write(res[:content]) if res[:role] == :assistant

      User.new
    end
  end
end
