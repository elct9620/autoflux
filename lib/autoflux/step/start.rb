# frozen_string_literal: true

module Autoflux
  module Step
    # The Start step is used to start the workflow.
    class Start
      def name = self.class.name || "Start"
      def call(**) = Command.new
    end
  end
end
