# frozen_string_literal: true

module Autoflux
  module Step
    # The Start step is used to start the workflow.
    class Start < Base
      def call(**) = Command.new
    end
  end
end
