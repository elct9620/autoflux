# frozen_string_literal: true

require "autoflux/stdio"

RSpec.describe Autoflux::Workflow do
  subject(:workflow) { described_class.new(agent: agent, io: io) }
  let(:io) { Autoflux::Stdio.new(input: StringIO.new("Hello\n")) }
  let(:agent) do
    lambda { |prompt, **|
      "#{prompt}, I am a helpful assistant"
    }
  end

  it { is_expected.to have_attributes(id: a_string_matching(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)) }

  context "when the agent is nil" do
    let(:agent) { nil }

    it { expect { workflow }.to raise_error(Autoflux::Error, "No agent provided") }
  end

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
          an_instance_of(Autoflux::Step::Agent),
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
    it { expect { run }.to output("Hello, I am a helpful assistant\n").to_stdout }

    context "when run with a block" do
      subject(:run) { workflow.run(&:stop) }

      it "is expected to control workflow when running" do
        expect { run }
          .to change(workflow, :step)
          .from(an_instance_of(Autoflux::Step::Start))
          .to(an_instance_of(Autoflux::Step::Stop))
      end
    end
  end

  describe "#switch_agent" do
    subject(:switch_agent) { workflow.switch_agent(name) }
    let(:workflow) { described_class.new(agents: agents, io: io) }
    let(:name) { "agent2" }

    let(:agents) { [agent, agent2] }
    let(:agent) { instance_double("Autoflux::OpenAI::Agent", name: "agent") }
    let(:agent2) { instance_double("Autoflux::OpenAI::Agent", name: "agent2") }

    it { is_expected.to be_truthy }
    it { expect { switch_agent }.to change(workflow, :agent).from(agent).to(agent2) }

    context "when the agent is not found" do
      let(:name) { "unknown" }

      it { expect { switch_agent }.not_to change(workflow, :agent) }
    end
  end
end
