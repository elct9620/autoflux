# frozen_string_literal: true

module Autoflux
  # The Invocation is store the tool invocation information.
  class Invocation
    attr_reader :id, :name, :args

    def initialize(id:, name:, args: "{}")
      @id = id
      @name = name
      @args = args
      freeze
    end
  end
end
