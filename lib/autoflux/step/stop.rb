# frozen_string_literal: true

module Autoflux
  module Step
    # The Stop step is used to stop the workflow.
    class Stop
      def name = self.class.name || "Stop"
      def call(**) = nil
    end
  end
end
