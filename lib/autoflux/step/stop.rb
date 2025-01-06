# frozen_string_literal: true

module Autoflux
  module Step
    # The Stop step is used to stop the workflow.
    class Stop < Base
      def call(**) = nil
    end
  end
end
