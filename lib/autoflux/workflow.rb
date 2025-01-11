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
        return SecureRandom.uuid_v7 if RUBY_VERSION >= "3.3" # steep:ignore

        SecureRandom.uuid
      end
    end

    include Enumerable

    attr_reader :id, :agent, :io, :agents

    # @rbs state: State
    def initialize(io:, agent: nil, agents: [], id: nil, step: Step::Start.new)
      @id = id || Workflow.next_id
      @agent = agent || agents.first
      @agents = agents
      @io = io
      @step = step

      raise Error, "No agent provided" unless @agent
    end

    def each
      return to_enum(:each) unless block_given?

      loop do
        break unless @step

        yield self
        @step = step.call(workflow: self)
      end
    end

    # Run the workflow.
    def run(&block)
      each(&block || ->(_workflow) {})
    end

    # Switch the agent.
    def switch_agent(name)
      new_agent = agents.find { |agent| agent.name == name }
      return false unless new_agent

      @agent = new_agent
      true
    end

    # Stop the workflow.
    def stop
      @step = Step::Stop.new
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
        step: step.to_s
      }
    end
  end
end
