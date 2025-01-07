# frozen_string_literal: true

module Autoflux
  # The Memory is a class to store the memory of the workflow.
  class Memory
    attr_reader :data, :verbose

    # @rbs data: Array[Hash]
    def initialize(data: [], verbose: false)
      @data = data
      @verbose = verbose
      freeze
    end

    # Push the data to the memory.
    #
    # @rbs data: Hash
    def push(event)
      puts JSON.pretty_generate(event) if verbose
      @data.push(event)
    end

    # Get the last data from the memory.
    def last
      @data.last
    end
  end
end
