# frozen_string_literal: true

module Autoflux
  # The workflow is a state machine to manage the flow of agentic AI.
  class Workflow
    attr_reader :state

    # @rbs state: State
    def initialize(state: nil)
      @state = state
    end

    # Run the workflow.
    def run
      @state = @state.call until @state.nil?
    end
  end
end
