# frozen_string_literal: true

module Autoflux
  module Step
    # The Step::Base is abstract class to represent the interface of the state
    class Base
      # @rbs workflow: Workflow
      def call(**)
        raise NotImplementedError
      end

      def name
        self.class.name || "Step"
      end
    end
  end
end
