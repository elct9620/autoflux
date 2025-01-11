# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "dotenv"
  gem "ruby-openai"
  gem "autoflux"
  gem "autoflux-openai"
end

Dotenv.load

require "autoflux/stdio"

# :nodoc:
class Memory
  attr_reader :verbose

  def initialize(initial = [], verbose: false)
    @memory = initial
    @verbose = verbose
  end

  def <<(message)
    puts JSON.pretty_generate(message) if verbose
    @memory.push(message)
  end

  def to_a
    @memory
  end
end

memory = Memory.new([
                      { role: "system", content: <<~PROMPT
                        You are a bookstore shopping AI assistant. Your mission is:

                        1. According to the book name and quantity provided by the user
                        2. When the information is incomplete, actively ask for the missing product name and quantity
                        3. When the tool cannot be used, try at most three times and return an error message
                        4. Switch to another agent when necessary

                        Do not provide any additional explanations or judgments, just return the function call.
                      PROMPT
                      }
                    ], verbose: ARGV.include?("--verbose"))

transfer = Autoflux::OpenAI::Tool.new(
  name: "transfer",
  description: "Transfer the agent to another agent, available agents: shopping, checkout",
  parameters: {
    type: "object",
    properties: {
      name: { type: "string", description: "The name of the agent" }
    },
    required: %w[name]
  }
) do |params, workflow:|
  success = workflow.switch_agent(params[:name])
  {
    success: success,
    message: success ? "Switched to #{params[:name]}" : "Failed to switch to #{params[:name]}"
  }
end

cart = Autoflux::OpenAI::Tool.new(
  name: "add_to_cart",
  description: "Add product to the shopping cart",
  parameters: {
    type: "object",
    properties: {
      name: { type: "string", description: "The name of the product" },
      quantity: { type: "integer", description: "The quantity of the product" }
    },
    required: %w[name quantity]
  }
) do |params|
  { success: true, message: "Added #{params[:quantity]} #{params[:name]} to the cart" }
end

checkout = Autoflux::OpenAI::Tool.new(
  name: "checkout",
  description: "Clean the cart and checkout"
) do
  { success: true, message: "Checkout the cart" }
end

shop_agent = Autoflux::OpenAI::Agent.new(
  name: "shopping",
  model: "gpt-4o-mini",
  memory: memory,
  tools: [cart, transfer]
)

checkout_agent = Autoflux::OpenAI::Agent.new(
  name: "checkout",
  model: "gpt-4o-mini",
  memory: memory,
  tools: [checkout, transfer]
)

workflow = Autoflux::Workflow.new(
  agents: [shop_agent, checkout_agent],
  io: Autoflux::Stdio.new(prompt: "> ")
)

ARGV.clear # Conflict with STDIN
workflow.run
