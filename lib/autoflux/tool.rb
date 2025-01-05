# frozen_string_literal: true

module Autoflux
  # The Tool is a abstract class to represent the adapter of tools which can be used by the Language Model.
  class Tool
    attr_reader :name, :description, :parameters

    def initialize(name:, description:, parameters: nil)
      @name = name
      @description = description
      @parameters = parameters
      freeze
    end

    def call(**)
      raise NotImplementedError
    end
  end
end
