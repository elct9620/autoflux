# frozen_string_literal: true

module Autoflux
  # The Start state is used to start the workflow.
  class Start < State
    def call(**) = User.new
  end
end
