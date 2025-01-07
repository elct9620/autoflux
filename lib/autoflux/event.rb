# frozen_string_literal: true

module Autoflux
  # Event is basic class for keeping events in workflow
  class Event
    ROLE_ASSISTANT = "assistant"
    ROLE_USER = "user"
    ROLE_SYSTEM = "system"

    attr_reader :role, :content, :invocations, :invocation_id

    def initialize(role:, content: nil, invocations: [], invocation_id: nil)
      @role = role
      @content = content
      @invocations = invocations
      @invocation_id = invocation_id
    end

    def system? = role == ROLE_SYSTEM
    def user? = role == ROLE_USER
    def assistant? = role == ROLE_ASSISTANT
  end
end
