# frozen_string_literal: true

require_relative "autoflux/version"

# The Autoflux is a lightweight AI agent framework.
module Autoflux
  class Error < StandardError; end

  require_relative "autoflux/tool"
  require_relative "autoflux/agent"
  require_relative "autoflux/io"
  require_relative "autoflux/memory"
  require_relative "autoflux/state"
  require_relative "autoflux/start"
  require_relative "autoflux/user"
  require_relative "autoflux/assistant"
  require_relative "autoflux/tools"
  require_relative "autoflux/stop"
  require_relative "autoflux/workflow"
end
