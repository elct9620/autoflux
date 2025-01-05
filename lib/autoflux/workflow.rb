# frozen_string_literal: true

module Autoflux
  # The workflow is a state machine to manage the flow of agentic AI.
  class Workflow
    attr_reader :state, :memory

    # @rbs state: State
    def initialize(state: nil, memory: Memory.new)
      @state = state
      @memory = memory
    end

    # Run the workflow.
    #
    # @rbs system_prompt: String?
    def run(system_prompt: nil)
      memory.push(role: :system, content: system_prompt) unless system_prompt.nil?
      @state = @state.call(workflow: self) until @state.nil?
    end
  end
end
