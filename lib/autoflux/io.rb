# frozen_string_literal: true

module Autoflux
  # The IO is abstract class to represent the interface of the IO
  class IO
    def read
      raise NotImplementedError
    end

    # @rbs data: String
    def write(_)
      raise NotImplementedError
    end
  end
end
