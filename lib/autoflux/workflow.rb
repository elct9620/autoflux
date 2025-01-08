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

    attr_reader :id, :agent, :io

    # @rbs state: State
    def initialize(agent:, io:, id: nil, step: Step::Start.new)
      @id = id || Workflow.next_id
      @agent = agent
      @io = io
      @step = step
      @events = []
    end

    def each
      return to_enum(:each) unless block_given?

      yield self
      while @step
        @step = step.call(workflow: self)
        yield self if @step
      end
    end

    # Run the workflow.
    def run(&block)
      each(&block || ->(_workflow) {})
    end

    # Stop the workflow.
    def stop
      @step = Step::Stop.new
    end

    # Get the current step. If the step is nil, return a Stop step.
    def step
      @step || Step::Stop.new
    end

    def events
      @events.clone
    end

    def apply(event)
      # @type var event: event
      event = event.freeze
      @events.push(event)
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
