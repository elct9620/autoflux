# frozen_string_literal: true

module Autoflux
  # The Step means a state in the workflow
  module Step
    require "autoflux/step/start"
    require "autoflux/step/stop"
    require "autoflux/step/command"
    require "autoflux/step/agent"
  end
end
