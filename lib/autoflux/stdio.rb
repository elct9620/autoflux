# frozen_string_literal: true

module Autoflux
  # The Stdio is a class to represent the standard input/output.
  class Stdio < IO
    # @rbs input: IO
    # @rbs output: IO
    def initialize(input: $stdin, output: $stdout)
      super()

      @input = input
      @output = output
      freeze
    end

    def read
      @input.gets.chomp
    end

    # @rbs data: String
    def write(data)
      @output.puts(data)
    end
  end
end
