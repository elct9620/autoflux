# frozen_string_literal: true

require "securerandom"

module Autoflux
  # The workflow is a state machine to manage the flow of agentic AI.
  class Workflow
    class << self
      # Generate a random UUID.
      #
      # @return [String]
      def next_id
        return SecureRandom.uuid_v7 if RUBY_VERSION >= "3.0"

        SecureRandom.uuid
      end
    end

    attr_reader :id, :agent, :memory, :io

    # @rbs state: State
    def initialize(agent:, io:, id: nil, step: Step::Start.new, memory: Memory.new)
      @id = id || Workflow.next_id
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

    # Get the current step. If the step is nil, return a Stop step.
    def step
      @step || Step::Stop.new
    end

    # Get the hash representation of the workflow.
    #
    # @return [Hash]
    def to_h
      {
        id: id,
        step: step.class.name
      }
    end
  end
end
