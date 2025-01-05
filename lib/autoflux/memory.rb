# frozen_string_literal: true

module Autoflux
  # The Memory is a class to store the memory of the workflow.
  class Memory
    attr_reader :data

    # @rbs data: Array[Hash]
    def initialize(data: [])
      @data = data
      freeze
    end

    # Push the data to the memory.
    #
    # @rbs data: Hash
    def push(data)
      @data.push(data)
    end

    # Get the last data from the memory.
    def last
      @data.last
    end
  end
end
