# frozen_string_literal: true

require_relative "autoflux/version"

# The Autoflux is a lightweight AI agent framework.
module Autoflux
  class Error < StandardError; end

  require_relative "autoflux/tool"
  require_relative "autoflux/agent"
  require_relative "autoflux/memory"
  require_relative "autoflux/step"
  require_relative "autoflux/workflow"
end
