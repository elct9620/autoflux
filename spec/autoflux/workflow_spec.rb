# frozen_string_literal: true

require "autoflux/stdio"

RSpec.describe Autoflux::Workflow do
  subject(:workflow) { described_class.new(agent: agent, io: io, step: step) }
  let(:io) { Autoflux::Stdio.new(input: StringIO.new("Hello\nexit")) }
  let(:step) { Autoflux::Start.new }
  let(:agent) { dummy_agent.new }
  let(:dummy_agent) do
    Class.new(Autoflux::Agent) do
      def call(**)
        { "role" => "assistant", "content" => "Hello, I am a helpful assistant" }
      end
    end
  end

  describe "#run" do
    subject(:run) { workflow.run }

    it { is_expected.to be_nil }

    context "when the state is abstract" do
      let(:step) { Autoflux::State.new }

      it { expect { run }.to raise_error(NotImplementedError) }
    end

    context "when the agent is abstract" do
      let(:agent) { Autoflux::Agent.new }

      it { expect { run }.to raise_error(NotImplementedError) }
    end

    context "when the agent returns non-exist tools" do
      before do
        allow(agent).to receive(:call).and_return(
          { role: :assistant,
            "tool_calls" => [{ "function" => { "name" => "dummy", "arguments" => "{}" }, "id" => "dummy-id" }] },
          { role: :assistant, content: "Hello, I am a helpful assistant" }
        )
      end

      it do
        expect { run }
          .to change(workflow.memory, :data)
          .from([])
          .to([
                { role: :user, content: "Hello" },
                { role: :assistant,
                  "tool_calls" => [{ "function" => { "name" => "dummy", "arguments" => "{}" }, "id" => "dummy-id" }] },
                { role: :tool, content: '{"status":"error","message":"Tool not found"}', tool_call_id: "dummy-id" },
                { role: :assistant, content: "Hello, I am a helpful assistant" }
              ])
      end
    end

    context "when the agent runs tools" do
      let(:dummy_tool) do
        Class.new(Autoflux::Tool) do
          def call(**)
            { status: "success", message: "Hello, I am a dummy tool" }
          end
        end
      end
      let(:agent) do
        dummy_agent.new(tools: [dummy_tool.new(name: "dummy", description: "A dummy tool")])
      end

      before do
        allow(agent).to receive(:call).and_return(
          { role: :assistant,
            "tool_calls" => [{ "function" => { "name" => "dummy", "arguments" => "{}" }, "id" => "dummy-id" }] },
          { role: :assistant, content: "Hello, I am a helpful assistant" }
        )
      end

      it do
        expect { run }
          .to change(workflow.memory, :data)
          .from([])
          .to([
                { role: :user, content: "Hello" },
                { role: :assistant,
                  "tool_calls" => [{ "function" => { "name" => "dummy", "arguments" => "{}" }, "id" => "dummy-id" }] },
                { role: :tool, content: '{"status":"success","message":"Hello, I am a dummy tool"}',
                  tool_call_id: "dummy-id" },
                { role: :assistant, content: "Hello, I am a helpful assistant" }
              ])
      end
    end

    context "when the system prompt is given" do
      subject(:run) { workflow.run(system_prompt: system_prompt) }
      let(:system_prompt) { "Hello, I am a helpful assistant" }

      it do
        expect { run }
          .to change(workflow.memory, :data)
          .from([])
          .to([
                { role: :system, content: "Hello, I am a helpful assistant" },
                { role: :user, content: "Hello" },
                { "role" => "assistant", "content" => "Hello, I am a helpful assistant" }
              ])
      end

      it { expect { run }.to output("Hello, I am a helpful assistant\n").to_stdout }
    end
  end
end
