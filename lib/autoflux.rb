# frozen_string_literal: true

require_relative "autoflux/version"

# The Autoflux is a lightweight AI agent framework.
module Autoflux
  class Error < StandardError; end

  require_relative "autoflux/workflow"
  require_relative "autoflux/state"
  require_relative "autoflux/stop"
end
