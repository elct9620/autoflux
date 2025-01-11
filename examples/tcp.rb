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

require "socket"

posts = Autoflux::OpenAI::Tool.new(
  name: "posts",
  description: "Get latest 3 posts"
) do |_params|
  posts = Net::HTTP.get(URI("https://jsonplaceholder.typicode.com/posts"))
  JSON.parse(posts).first(3)
rescue JSON::ParserError
  { error: "Failed to parse the response" }
end

server = TCPServer.new(9001)

# :nodoc:
class SocketIO
  def initialize(io)
    @io = io
  end

  def read
    @io.print("> ")
    input = @io.gets
    return nil if input.nil?
    return nil if input.chomp == "exit"

    input.chomp
  end

  def write(message)
    @io.puts(message)
  end

  def close
    @io.close
  end
end

puts "Server is running on :9001"

loop do
  Thread.start(server.accept) do |client|
    puts "New connection"

    io = SocketIO.new(client)
    agent = Autoflux::OpenAI::Agent.new(
      model: "gpt-4o-mini",
      memory: [
        { role: "system", content: <<~PROMPT
          You are a social media AI assistant. Your mission is:

          1. Find the latest 3 posts
          2. When the information is incomplete, actively ask for the missing information
          3. When the tool cannot be used, try at most three times and return an error message

          Do not provide any additional explanations or judgments, just return the function call.
        PROMPT
        }
      ],
      tools: [posts]
    )

    workflow = Autoflux::Workflow.new(agent: agent, io: io)
    workflow.run
    puts "Connection closed"

    io.close
  end
end
