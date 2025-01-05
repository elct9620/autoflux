# frozen_string_literal: true

module Autoflux
  # The Stop state is used to stop the workflow.
  class Stop < State
    def call(**) = nil
  end
end
