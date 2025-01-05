# frozen_string_literal: true

RSpec.describe Autoflux::Workflow do
  subject(:workflow) { described_class.new(state: state) }
  let(:state) { nil }

  describe "#run" do
    subject(:run) { workflow.run }

    it { is_expected.to be_nil }

    context "when the state is abstract" do
      let(:state) { Autoflux::State.new }

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
                { role: :system, content: "Hello, I am a helpful assistant" }
              ])
      end
    end
  end
end
