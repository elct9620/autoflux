# frozen_string_literal: true

require_relative "autoflux/version"

# The Autoflux is a lightweight AI agent framework.
module Autoflux
  class Error < StandardError; end

  ROLE_SYSTEM = "system"
  ROLE_ASSISTANT = "assistant"
  ROLE_TOOL = "tool"
  ROLE_USER = "user"

  require_relative "autoflux/step"
  require_relative "autoflux/workflow"
end
