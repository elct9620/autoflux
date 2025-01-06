# frozen_string_literal: true

module Autoflux
  # The workflow is a state machine to manage the flow of agentic AI.
  class Workflow
    attr_reader :agent, :memory, :io

    # @rbs state: State
    def initialize(agent:, io:, step: Start.new, memory: Memory.new)
      @agent = agent
      @io = io
      @step = step
      @memory = memory
    end

    # Run the workflow.
    #
    # @rbs system_prompt: String?
    def run(system_prompt: nil)
      memory.push(role: :system, content: system_prompt) unless system_prompt.nil?
      @step = step.call(workflow: self) until @step.nil?
    end

    def step
      @step || Step::Stop.new
    end
  end
end
