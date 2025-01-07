# frozen_string_literal: true

require "autoflux/stdio"

RSpec.describe Autoflux::Workflow do
  subject(:workflow) { described_class.new(agent: agent, io: io) }
  let(:io) { Autoflux::Stdio.new(input: StringIO.new("Hello\nexit")) }
  let(:agent) { dummy_agent.new }
  let(:dummy_agent) do
    Class.new(Autoflux::Agent) do
      def call(**)
        { "role" => "assistant", "content" => "Hello, I am a helpful assistant" }
      end
    end
  end

  it { is_expected.to have_attributes(id: a_string_matching(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)) }

  describe "#step" do
    subject { workflow.step }
    let(:workflow) { described_class.new(agent: agent, io: io, step: step) }
    let(:step) { Autoflux::Step::Start.new }

    it { is_expected.to be_a(Autoflux::Step::Start) }

    context "when the step is nil" do
      let(:step) { nil }

      it { is_expected.to be_a(Autoflux::Step::Stop) }
    end
  end

  describe "#to_h" do
    subject(:to_h) { workflow.to_h }
    let(:workflow) { described_class.new(id: "custom-id", agent: agent, io: io, step: step) }
    let(:step) { Autoflux::Step::Start.new }

    it { is_expected.to include(id: "custom-id", step: "Autoflux::Step::Start") }

    context "when the step is nil" do
      let(:step) { nil }

      it { is_expected.to include(id: "custom-id", step: "Autoflux::Step::Stop") }
    end
  end

  describe "#stop" do
    subject(:stop) { workflow.stop }

    it "is expected to stopped" do
      expect { stop }
        .to change(workflow, :step)
        .from(an_instance_of(Autoflux::Step::Start))
        .to(an_instance_of(Autoflux::Step::Stop))
    end
  end

  describe "#each" do
    subject(:each) { workflow.each }

    it { is_expected.to be_an(Enumerator) }

    it "is expected to step in 2 step" do
      expect { each.take(2) }
        .to change { workflow.step }
        .from(an_instance_of(Autoflux::Step::Start))
        .to(an_instance_of(Autoflux::Step::Command))
    end

    it "is expected to run all steps" do
      expect(each.map(&:step))
        .to contain_exactly(
          an_instance_of(Autoflux::Step::Start),
          an_instance_of(Autoflux::Step::Command),
          an_instance_of(Autoflux::Step::Assistant),
          an_instance_of(Autoflux::Step::Command),
          an_instance_of(Autoflux::Step::Stop)
        )
    end
  end

  describe "#to_enum" do
    subject(:to_enum) { workflow.to_enum }

    it { is_expected.to be_an(Enumerator) }

    it "is expected to step in 2 step" do
      expect { to_enum.take(2) }
        .to change { workflow.step }
        .from(an_instance_of(Autoflux::Step::Start))
        .to(an_instance_of(Autoflux::Step::Command))
    end
  end

  describe "#run" do
    subject(:run) { workflow.run }

    it { is_expected.to be_nil }

    context "when the state is abstract" do
      let(:workflow) { described_class.new(agent: agent, io: io, step: step) }
      let(:step) { Autoflux::Step::Base.new }

      it { expect { run }.to raise_error(NotImplementedError) }
    end

    context "when the agent is abstract" do
      let(:agent) { Autoflux::Agent.new }

      it { expect { run }.to raise_error(NotImplementedError) }
    end

    context "when run with a block" do
      subject(:run) { workflow.run(&:stop) }

      it "is expected to control workflow when running" do
        expect { run }
          .to change(workflow, :step)
          .from(an_instance_of(Autoflux::Step::Start))
          .to(an_instance_of(Autoflux::Step::Stop))
      end
    end

    context "when input is EOF" do
      let(:io) { Autoflux::Stdio.new(input: StringIO.new("Hello\n")) }

      it { expect { run }.to output("Hello, I am a helpful assistant\n").to_stdout }
      it "is expected to stopped when input reach EOF" do
        expect { run }
          .to change(workflow.memory, :data)
          .from([])
          .to([
                { role: :user, content: "Hello" },
                { "role" => "assistant", "content" => "Hello, I am a helpful assistant" }
              ])
      end
    end

    context "when the agent returns non-exist tools" do
      before do
        allow(agent).to receive(:call).and_return(
          { role: :assistant,
            "tool_calls" => [{ "function" => { "name" => "dummy", "arguments" => "{}" }, "id" => "dummy-id" }] },
          { role: :assistant, content: "Hello, I am a helpful assistant" }
        )
      end

      it "is expected to see tool not found message" do
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

      it "is expected to call the tool" do
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

      it "is expected to add system prompt" do
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
