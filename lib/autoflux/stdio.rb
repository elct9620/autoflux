# frozen_string_literal: true

module Autoflux
  # The Stdio is a class to represent the standard input/output.
  class Stdio
    attr_accessor :prompt

    # @rbs input: IO
    # @rbs output: IO
    def initialize(input: $stdin, output: $stdout, prompt: nil)
      @input = input
      @output = output
      @prompt = prompt
      freeze
    end

    def read
      print prompt if prompt
      @input.gets&.chomp
    end

    # @rbs data: String
    def write(data)
      @output.puts(data)
    end
  end
end
