# frozen_string_literal: true

require "autoflux/stdio"

RSpec.describe Autoflux::Workflow do
  subject(:workflow) { described_class.new(agent: agent, io: io, state: state) }
  let(:io) { Autoflux::Stdio.new(input: StringIO.new("Hello\nexit")) }
  let(:state) { Autoflux::User.new }
  let(:agent) { dummy_agent.new }
  let(:dummy_agent) do
    Class.new(Autoflux::Agent) do
      def call(**)
        { role: :assistant, content: "Hello, I am a helpful assistant" }
      end
    end
  end

  describe "#run" do
    subject(:run) { workflow.run }

    it { is_expected.to be_nil }

    context "when the state is abstract" do
      let(:state) { Autoflux::State.new }

      it { expect { run }.to raise_error(NotImplementedError) }
    end

    context "when the agent is abstract" do
      let(:agent) { Autoflux::Agent.new }

      it { expect { run }.to raise_error(NotImplementedError) }
    end

    context "when the state is a concrete state" do
      let(:state) { Autoflux::Stop.new }

      it { is_expected.to be_nil }
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
                { role: :assistant, content: "Hello, I am a helpful assistant" }
              ])
      end

      it { expect { run }.to output("Hello, I am a helpful assistant\n").to_stdout }
    end
  end
end
